/*
 *  license-start
 *  
 *  Copyright (C) 2021 Ministero della Salute and all other contributors
 *  
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  
 *      http://www.apache.org/licenses/LICENSE-2.0
 *  
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
*/

//
//  DRLSynchronizationManager.swift
//  Verifier
//
//  Created by Andrea Prosseda on 07/09/21.
//

import Foundation
import UIKit
import RxSwift
import RxCocoaRuntime

protocol DRLSynchronizationDelegate {
    func statusDidChange(with result: DRLSynchronizationManager.Result)
}

class DRLSynchronizationManager {
    
    let AUTOMATIC_MAX_SIZE: Double = 5.0.fromMegaBytesToBytes
    
    enum DRLStatusError: Error {
        case illegalChunkNumber
    }
    
    enum DRLDownloadError: Error {
        case versionMismatch
    }
    
    enum Result {
        case downloadReady
        case downloading
        case completed
        case paused
        case error
        case statusNetworkError
        case noConnection
        
        /// DRL snapshot size grater than `AUTOMATIC_MAX_SIZE`
        case userInteractionRequired
    }
    
    static let shared = DRLSynchronizationManager()
    var firstRun: Bool = true
    var drlStatusFailCounter: Int {
        get {return _drlStatusFailCounter }
        set {_drlStatusFailCounter = newValue}
    }
    var drlFailCounter: Int {
        get {return _drlFailCounter }
        set {_drlFailCounter = newValue}
    }
    
    var progress: DRLProgress { _progress }
    var gateway: GatewayConnection { GatewayConnection.shared }
    
    private var delegate: DRLSynchronizationDelegate?
    private var timer: Timer?
    
    private var isDownloadingDRL: Bool = false
    
    private var _serverStatus: DRLStatus?
    private var _progress: DRLProgress
    {
        get { DRLDataStorage.shared.progress ?? .init() }
        set { DRLDataStorage.shared.saveProgress(newValue) }
    }
    private var _drlStatusFailCounter: Int = 1
    private var _drlFailCounter: Int = 1
    
    
    let disposeBag = DisposeBag()
    
    private var maxRetries: Int {
        return LocalData.getSetting(from: Constants.drlMaxRetries)?.intValue ?? 1
    }

    var isSyncEnabled: Bool {
        LocalData.getSetting(from: "DRL_SYNC_ACTIVE")?.boolValue ?? true
    }
    

    private func getHttpErrorCode(from error: Error) -> Int? {
        guard let gatewayError = error as? GCError else { return nil }
        switch gatewayError {
        case .httpError(let code):
            return code
        default:
            return nil
        }
    }
    
    private func isaServerTimeoutError(_ error: Error) -> Bool {
        return self.getHttpErrorCode(from: error) == 408
    }
    
    func initialize(delegate: DRLSynchronizationDelegate?) {
        guard isSyncEnabled else { return }
        log("initialize")
        self.delegate = delegate
        //setTimer() { self.start() }
        drlFailCounter = maxRetries
        drlStatusFailCounter = maxRetries
        self.start()
    }
    
    private func resetStatusFailsCounter() {
        self.drlStatusFailCounter = self.maxRetries
    }
    
    private func resetDrlFailsCounter() {
        self.drlFailCounter = self.maxRetries
    }
    
    private func getDRLStatus (progress: DRLProgress) -> RxSwift.Observable<DRLStatus> {
        return gateway.getDRLStatus(progress).do { newStatus in
            self.resetStatusFailsCounter()
            self._serverStatus = newStatus
            self._progress = .init(serverStatus: newStatus)
        } onError: { error in
            self.log("[getDRLStatus] Error = \(error)")
            self.handleStatusError(error)
        } onCompleted: {
            self.log("[getDRLStatus] Completed")
        } onSubscribe: {
            self.log("[getDRLStatus] Subscribed")
        } onDispose: {
            self.log("[getDRLStatus] Disposed")
        }
    }
    
//    private func getDRLStatus (progress: DRLProgress) -> RxSwift.Observable<DRLStatus> {
//        return gateway.getDRLStatus(progress).do { newStatus in
//            self.resetStatusFailsCounter()
//        } onError: { error in
//            self.log("[getDRLStatus] Error = \(error)")
//            self.handleStatusError(error)
//        } onCompleted: {
//            self.log("[getDRLStatus] Completed")
//        } onSubscribe: {
//            self.log("[getDRLStatus] Subscribed")
//        } onDispose: {
//            self.log("[getDRLStatus] Disposed")
//        }
//    }
    
    private func getDRL (progress: DRLProgress, allowMaxSizeDownload: Bool) -> RxSwift.Observable<DRL> {
        return downloadChunks(progress: progress, allowMaxSizeDownload: allowMaxSizeDownload).do { drl in
            self.log("Downloaded chunk: \(String(describing: drl.id))")
            self.saveDRL(drl: drl)
        } onError: { error in
            self.log("[getDRL] Error = \(error)")
            self.handleRetry()
        } onCompleted: {
            // all chunks downloaded
            self.log("[getDRL] Completed")
            self._progress.completeProgress()
            self._serverStatus = nil
            self.resetDrlFailsCounter()
            DRLDataStorage.shared.lastFetch = Date()
            DRLDataStorage.shared.save()
            self.isDownloadingDRL = false
            self.notifyStatusChange(newStatus: .completed)
        } onSubscribe: {
            self.log("[getDRL] Subscribed")
        } onDispose: {
            self.log("[getDRL] Disposed")
        }
    }
    
    private func downloadChunks(progress: DRLProgress, allowMaxSizeDownload: Bool) -> RxSwift.Observable<DRL> {
        let currentVersion = progress.currentVersion
        let requesterVersion = progress.requestedVersion
        let currentChunk = progress.currentChunk ?? 1
        let totalChunk = progress.totalChunk ?? 1
        guard currentChunk > 0 else { return RxSwift.Observable.error(DRLStatusError.illegalChunkNumber) }
        let downloadList = (currentChunk ... totalChunk).map{
            downloadChunk(version: currentVersion, requestedVersion: requesterVersion, chunk: $0, allowMaxSizeDownload: allowMaxSizeDownload)
        }
        return RxSwift.Observable.concat(downloadList)
    }

    private func downloadChunk(version: Int, requestedVersion: Int, chunk: Int, allowMaxSizeDownload: Bool) -> RxSwift.Observable<DRL> {
        return gateway.getDRLChunk(version: version, chunk: chunk)
            .do { drl in
                // todo move this code in another observable
                guard drl.version == requestedVersion else {
                    throw DRLDownloadError.versionMismatch
                }
            }
    }
    
    private func saveDRL (drl: DRL) {
        self.log("managing response")
        DRLDataStorage.store(drl: drl)
        self.notifyStatusChange(newStatus: .downloading)
        if self.progress.currentChunk != self.progress.totalChunk {
            self._progress.updateProgress(with: drl.sizeSingleChunkInByte)
        }
    }
    
    func test (progress: DRLProgress, allowMaxSizeDownload: Bool) -> RxSwift.Observable<Void>{
        return RxSwift.Observable<Void>.create { observer in
            self.gateway.getDRLStatus(progress)
                .flatMap { drlStatus -> RxSwift.Observable<DRL> in
                    self.resetStatusFailsCounter()
                    self._serverStatus = drlStatus
                    self._progress = .init(serverStatus: drlStatus)
                    return self.downloadChunks(progress: self.progress, allowMaxSizeDownload: allowMaxSizeDownload)
                }
                .subscribe { drl in
                    print ("DRL")
                } onError: { error in
                    let err = error as! testError
                    print ("ERROR :\(err)")
                } onCompleted: {
                    print ("COMPLETED")
                }

            return Disposables.create()
        }
    }
    
    func start(allowMaxSizeDownload: Bool = false) {
        log("check status")
        
        guard outdatedVersion else {
            return
        }
        guard noPendingDownload else {
            resumeDownload()
            return
        }
        
        test(progress: progress, allowMaxSizeDownload: allowMaxSizeDownload).subscribe()
        
        
//        EMILIO GIOVANNI
//        getDRLStatus(progress: progress).subscribe {event in
//            switch event{
//            case .next(let status):
//                print ("[DRLStatus: \(status)]")
//                self.getDRL(progress: self.progress, allowMaxSizeDownload: allowMaxSizeDownload).subscribe { evnt in
//                    switch event {
//                    case .next(let drl):
//                        print ("DRL scaricate: \(String(describing: drl.totalNumberUCVI))")
//                        print ("DRL memorizzate: \(DRLDataStorage.drlTotalNumber())")
//                    case .error(let error):
//                        print ("Error in getDRL: \(error)")
//                    case .completed:
//                        print ("getDRL completed")
//                    }
//                }.disposed(by: self.disposeBag)
//            case .error(let error):
//                print ("Error in getDRLStatus: \(error)")
//            case .completed:
//                print ("getDRLStatus completed")
//            }
//        }.disposed(by: disposeBag)

//        LUDOVICO
//        gateway.getDRLStatus(progress)
//            .do(onNext: { newServerStatus in
//                self.resetStatusFailsCounter()
//                self._progress = DRLProgress(serverStatus: newServerStatus)
//            })
//            .concatMap({_ in
//                self.downloadChunks(allowMaxSizeDownload: allowMaxSizeDownload)
//            })
//            .subscribe { drl in
//                // call after chunk download
//                self.log("Downloaded chunk: \(drl.id)")
//                self.saveDRL(drl: drl)
//            } onError: { err in
//                self.log("Errore in getDRL = \(err)")
//                //handle chunk download error
//
//            } onCompleted: {
//                // all chunks downloaded
//                self._progress.completeProgress()
//                self._serverStatus = nil
//                self.resetDrlFailsCounter()
//                DRLDataStorage.shared.lastFetch = Date()
//                DRLDataStorage.shared.save()
//                self.isDownloadingDRL = false
//                self.notifyStatusChange(newStatus: .completed)
//
//            }
//            .disposed(by: disposeBag)
    }
    
//
//    private func synchronize() {
//        log("start synchronization")
//        guard outdatedVersion else {
//            downloadCompleted()
//            return
//        }
//        guard noPendingDownload else {
//            resumeDownload()
//            return
//        }
//        checkDownload()
//    }
//
//    private func checkDownload() {
//        _progress = DRLProgress(serverStatus: _serverStatus)
//
//        guard !requireUserInteraction else {
//            notifyStatusChange(newStatus: .userInteractionRequired)
//            //self.delegate?.statusDidChange(with: .userInteractionRequired)
//            return
//        }
//
//        startDownload()
//    }
//
//    func startDownload() {
//        guard Connectivity.isOnline else {
//            self.delegate?.statusDidChange(with: .noConnection)
//            return
//        }
//
//        isDownloadingDRL = true
//        download()
//    }
//
    private func resumeDownload() {
        log("resuming previous progress")

        if !sameChunkSize || !sameRequestedVersion {
            handleRetry()
            return
        }

        oneChunkAlreadyDownloaded ? self.notifyStatusChange(newStatus: .paused)
            : self.notifyStatusChange(newStatus: .downloadReady)
    }
//
//
//    private func downloadCompleted() {
//        log("download completed")
//        guard sameDatabaseSize else {
//            log("inconsistent number of UCVI, clean needed")
//            handleRetry()
//            return
//        }
//        _progress.completeProgress()
//        _serverStatus = nil
//        drlFailCounter = self.maxRetries
//        DRLDataStorage.shared.lastFetch = Date()
//        DRLDataStorage.shared.save()
//        isDownloadingDRL = false
//        self.notifyStatusChange(newStatus: .completed)
//    }
//
    func handleRetry() {
        self.drlFailCounter -= 1
        if self.drlFailCounter < 0 {
            log("failed too many times")
            if progress.remainingBytes == nil || progress.remainingBytes == 0  {
                notifyStatusChange(newStatus: .statusNetworkError)
            } else {
                notifyStatusChange(newStatus: .error)
            }
            clean()
        }
        else {
            log("retrying...")
            cleanAndRetry()
        }
    }

    func handleStatusError(_ error: Error) {
        self.drlStatusFailCounter -= 1

        if self.drlStatusFailCounter < 0 || !Connectivity.isOnline || isaServerTimeoutError(error) {
            self.delegate?.statusDidChange(with: .statusNetworkError)
        }
        else {
            self.cleanAndRetry()
        }
    }

    private func clean() {
        _progress = .init()
        _serverStatus = nil
        isDownloadingDRL = false
        DRLDataStorage.clear()
        log("cleaned")
    }

    private func cleanAndRetry() {
        log("clean needed, retry")
        clean()
        start()
    }
//
//    func download() {
//        guard chunksNotYetCompleted else { return downloadCompleted() }
//        log(progress)
//        notifyStatusChange(newStatus: .downloading)
//
//        print ("ERRORE DISTRUTTIVO")
//
////        gateway.updateRevocationList(progress) { drl, error, statusCode in
////            guard statusCode == 200 else { return self.handleDRLHTTPError(statusCode: statusCode) }
////            guard error == nil else { return self.errorFlow() }
////            guard let drl = drl else { return self.errorFlow() }
////            self.manageResponse(with: drl)
////        }
//    }
//
//
//    private func manageResponse(with drl: DRL) {
//        guard isConsistent(drl) else { return handleRetry() }
//        log("managing response")
//        DRLDataStorage.store(drl: drl)
//        _progress.updateProgress(with: drl.sizeSingleChunkInByte)
//        startDownload()
//    }
//
//    private func handleDRLHTTPError(statusCode: Int?) {
//        guard let statusCode = statusCode else {
//            return self.handleRetry()
//        }
//
//        switch statusCode {
//        case 400...407:
//            self.handleRetry()
//        case 408:
//            // 408 - Timeout: resume downloading from the last persisted chunk.
//            if Connectivity.isOnline {
//                self.notifyStatusChange(newStatus: .paused)
//            } else {
//                self.delegate?.statusDidChange(with: .noConnection)
//            }
//        default:
//            self.errorFlow()
//            log("there was an unexpected HTTP error, code: \(statusCode)")
//        }
//    }
    
    private func notifyStatusChange(newStatus status: Result) {
        delegate?.statusDidChange(with: status)
    }

    private func errorFlow() {
        _serverStatus = nil
        self.isDownloadingDRL = false
        delegate?.statusDidChange(with: .error)
    }

}


extension DRLSynchronizationManager {
    
    public var needsServerStatusUpdate: Bool {
        _serverStatus == nil
    }
        
    public var noPendingDownload: Bool {
        progress.currentVersion == progress.requestedVersion
    }
    
    private var outdatedVersion: Bool {
        _serverStatus?.version != _progress.currentVersion
    }
    
    private var sameRequestedVersion: Bool {
        _serverStatus?.version == _progress.requestedVersion
    }
    
    private var chunksNotYetCompleted: Bool { !noMoreChunks }
    
    private var noMoreChunks: Bool {
        guard let lastChunkDownloaded = _progress.currentChunk else { return false }
        guard let allChunks = _serverStatus?.totalChunk else { return false }
        return lastChunkDownloaded > allChunks
    }
    
    private var oneChunkAlreadyDownloaded: Bool {
        guard let currentChunk = _progress.currentChunk else { return true }
        return currentChunk > DRLProgress.FIRST_CHUNK
    }

    private var sameChunkSize: Bool {
        guard let localChunkSize = _progress.sizeSingleChunkInByte else { return false }
        guard let serverChunkSize = _serverStatus?.sizeSingleChunkInByte else { return false }
        return localChunkSize == serverChunkSize
    }
    
    /// Returns `true` if the download size is greater than `AUTOMATIC_MAX_SIZE`.
    private var requireUserInteraction: Bool {
        guard let size = _serverStatus?.totalSizeInByte else { return false }
        return size.doubleValue > AUTOMATIC_MAX_SIZE
    }

    private func isConsistent(_ drl: DRL) -> Bool {
        guard let drlVersion = drl.version else { return false }
        return drlVersion == progress.requestedVersion
    }
    
    var sameDatabaseSize: Bool {
        guard let serverStatus = _serverStatus, let serverTotalNumberUCVI = serverStatus.totalNumberUCVI else {return false}
        return serverTotalNumberUCVI == DRLDataStorage.drlTotalNumber()
    }
    
    private func log(_ message: String) {
        print("log.drl.sync - " + message)
    }
    
    private func log(_ progress: DRLProgress) {
        let from = progress.currentVersion
        let to = progress.requestedVersion
        let chunk = progress.currentChunk ?? DRLProgress.FIRST_CHUNK
        let chunks = progress.totalChunk ?? DRLProgress.FIRST_CHUNK
        log("downloading [\(from)->\(to)] \(chunk)/\(chunks)")
    }
}

extension DRLSynchronizationManager {
    
    func setTimer(completion: (()->())? = nil) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            self.trigger(completion: completion)
        }
        timer?.tolerance = 5.0
        self.trigger(completion: completion)
    }
    
    func trigger(completion: (()->())? = nil) {
        guard (isFetchOutdatedAndAllowed || firstRun) && !isDownloadingDRL else { return }
        firstRun = false
        completion?()
    }
    
    var isFetchOutdated: Bool {
        DRLDataStorage.shared.lastFetch.timeIntervalSinceNow < -24 * 60 * 60
    }
    
    var isFetchOutdatedAndAllowed: Bool {
        isSyncEnabled && DRLDataStorage.shared.lastFetch.timeIntervalSinceNow < -24 * 60 * 60
    }

}

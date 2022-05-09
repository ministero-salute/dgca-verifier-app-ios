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
//  DRLSynchronizer.swift
//  Verifier
//
//  Created by Johnny Bueti on 03/05/22.
//

import Foundation
import UIKit

class DRLSynchronizer {
    
    let AUTOMATIC_MAX_SIZE: Double = 5.0.fromMegaBytesToBytes
    
    var managerType: SyncManagerType
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
    var syncCompleted: Bool = false
    var syncStatus: DRLSynchronizationManager.Status?
    
    private var delegate: DRLSynchronizerDelegate?
    private var timer: Timer?
    
    private var isDownloadingDRL: Bool = false
    
    private var _serverStatus: DRLStatus?
    private var _progress: DRLProgress
    {
        get {
            self.managerType == .IT ? DRLDataStorage.shared.progress ?? .init() : DRLDataStorage.shared.progressEU ?? .init()
        }
        set {
            self.managerType == .IT ? DRLDataStorage.shared.saveProgress(newValue) : DRLDataStorage.shared.saveProgressEU(newValue)
        }
    }
    private var _drlStatusFailCounter: Int = 1
    private var _drlFailCounter: Int = 1
    
    init(managerType: SyncManagerType) {
        self.managerType = managerType
    }
    
    func initialize(delegate: DRLSynchronizerDelegate?) {
        guard isSyncEnabled else { return }
        log("initialize")
        self.delegate = delegate
        setTimer() { self.start() }
        drlFailCounter = LocalData.getSetting(from: Constants.drlMaxRetries)?.intValue ?? 1
        drlStatusFailCounter = LocalData.getSetting(from: Constants.drlMaxRetries)?.intValue ?? 1
    }
    
    func start() {
        log("check status")
        self.syncCompleted = false
        gateway.revocationStatus(managerType: self.managerType, progress) { (serverStatus, error, responseCode) in
            guard error == nil, responseCode == 200 else {
                self.log("status failed")
                
                if self.isFetchOutdated {
                    self.log("fetch outdated, scans not allowed")
                }
                
                return self.handleStatusRetry(responseCode: responseCode)
            }
            
            self.drlStatusFailCounter = LocalData.getSetting(from: Constants.drlMaxRetries)?.intValue ?? 1
            self._serverStatus = serverStatus
            self.synchronize()
        }
    }
    
    var isSyncEnabled: Bool {
        let isSyncEnabledSetting = managerType == .IT ? Constants.itRevocationIsEnabled : Constants.euRevocationIsEnabled
        return LocalData.getSetting(from: isSyncEnabledSetting)?.boolValue ?? true
    }
    
    private func synchronize() {
        log("start synchronization")
        guard outdatedVersion else { return downloadCompleted() }
        guard noPendingDownload else { return resumeDownload() }
        checkDownload()
    }
    
    func checkDownload() {
        _progress = DRLProgress(serverStatus: _serverStatus)
        guard !requireUserInteraction else {
            updateSyncStatus(status: .userInteractionRequired)
            return
        }
        startDownload()
    }
    
    func startDownload() {
        guard Connectivity.isOnline else {
            self.showNoConnectionAlert()
            self.resumeDownload()
            return
        }
        isDownloadingDRL = true
        download()
    }
    
    func resumeDownload() {
        log("resuming previous progress")
        guard sameChunkSize else { return handleRetry() }
        guard sameRequestedVersion else { return handleRetry() }
        guard oneChunkAlreadyDownloaded else { return readyToDownload() }
        readyToResume()
    }
    
    func readyToDownload() {
        log("user can download")
        updateSyncStatus(status: .downloadReady)
    }
    
    func readyToResume() {
        log("user can resume download")
        updateSyncStatus(status: .paused)
    }
    
    func downloadCompleted() {
        log("download completed")
        guard sameDatabaseSize else {
            log("inconsistent number of UCVI, clean needed")
            return handleRetry()
        }
        self.syncCompleted = true
        self.delegate?.signalDownloadCompleted(managerType: self.managerType)
        _serverStatus = nil
        drlFailCounter = LocalData.getSetting(from: Constants.drlMaxRetries)?.intValue ?? 1
        switch self.managerType {
        case .IT:
            DRLDataStorage.shared.lastFetch = Date()
        case .EU:
            DRLDataStorage.shared.lastFetchEU = Date()
        }
        DRLDataStorage.shared.save()
        isDownloadingDRL = false
        updateSyncStatus(status: .completed)
    }
    
    func handleRetry() {
        self.drlFailCounter -= 1
        if self.drlFailCounter < 0 {
            log("failed too many times")
            if progress.remainingSize == "0.00" || progress.remainingSize == "" {
                updateSyncStatus(status: .statusNetworkError)
            } else {
                updateSyncStatus(status: .error)
            }
            clean()
            return
        }
        else {
            log("retrying...")
            return cleanAndRetry()
        }
    }
    
    func handleStatusRetry(responseCode: Int?) {
        if responseCode != 408 {
            self.drlStatusFailCounter -= 1
        }
        
        if self.drlStatusFailCounter < 0 || !Connectivity.isOnline || responseCode == 408 {
            updateSyncStatus(status: .statusNetworkError)
        } else {
            self.cleanAndRetry()
        }
    }
    
    func clean() {
        _progress = .init()
        _serverStatus = nil
        isDownloadingDRL = false
        self.managerType == .IT ? DRLDataStorage.clearIT() : DRLDataStorage.clearEU()
        log("cleaned")
    }
    
    func cleanAndRetry() {
        log("clean needed, retry")
        clean()
        start()
    }
    
    func download() {
        guard chunksNotYetCompleted else { return downloadCompleted() }
        log(progress)
        updateSyncStatus(status: .downloading)
        gateway.updateRevocationList(managerType: self.managerType, progress) { drl, error, statusCode in
            guard statusCode == 200, error == nil else { return self.handleDRLHTTPError(statusCode: statusCode) }
            guard let drl = drl else { return self.errorFlow() }
            self.manageResponse(with: drl)
        }
    }
    
    private func manageResponse(with drl: DRL) {
        guard isConsistent(drl) else { return handleRetry() }
        log("managing response")
        DRLDataStorage.store(drl: drl, isEUDGC: self.managerType == .IT ? false : true)
        updateProgress(with: drl.sizeSingleChunkInByte)
        startDownload()
    }
    
    private func handleDRLHTTPError(statusCode: Int?) {
        guard let statusCode = statusCode else {
            return self.handleRetry()
        }
        
        switch statusCode {
            case 200:
                self.resumeDownload()
            case 400...407:
                self.handleRetry()
            case 408:
                // 408 - Timeout: resume downloading from the last persisted chunk.
                Connectivity.isOnline ? readyToResume() : showNoConnectionAlert()
            default:
                self.errorFlow()
                log("there was an unexpected HTTP error, code: \(statusCode)")
        }
    }
    
    private func errorFlow() {
        _serverStatus = nil
        self.isDownloadingDRL = false
        updateSyncStatus(status: .error)
    }
    
    private func updateProgress(with size: Int?) {
        let current = progress.currentChunk ?? DRLProgress.FIRST_CHUNK
        let downloadedSize = progress.downloadedSize ?? 0
        _progress.currentChunk = current + 1
        _progress.downloadedSize = downloadedSize + (size?.doubleValue ?? 0)
    }
    
    func completeProgress() {
        let completedVersion = progress.requestedVersion
        _progress = .init(version: completedVersion)
    }
    
    public func showNoConnectionAlert() {
        let content: AlertContent = .init(
            title: "alert.no.connection.title",
            message: "alert.no.connection.message",
            confirmAction: nil,
            confirmActionTitle: "alert.default.action",
            cancelAction: nil,
            cancelActionTitle: nil
        )
        
        UIApplication.showAppAlert(content: content)
    }
    
    private func updateSyncStatus(status: DRLSynchronizationManager.Status){
        self.syncStatus = status
        delegate?.statusDidChange(managerType: self.managerType)
    }
    
}

extension DRLSynchronizer {
    
    public var needsServerStatusUpdate: Bool {
        _serverStatus == nil
    }
    
    public var noPendingDownload: Bool {
        progress.currentVersion == progress.requestedVersion
    }
    
    public var outdatedVersion: Bool {
        _serverStatus?.version != _progress.currentVersion
    }
    
    public var sameRequestedVersion: Bool {
        _serverStatus?.version == _progress.requestedVersion
    }
    
    public var chunksNotYetCompleted: Bool { !noMoreChunks }
    
    public var noMoreChunks: Bool {
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
        switch self.managerType {
        case .IT:
            return serverTotalNumberUCVI == DRLDataStorage.drlTotalNumberIT()
        case .EU:
            return serverTotalNumberUCVI == DRLDataStorage.drlTotalNumberEU()
        }
    }
    
    private func log(_ message: String) {
        print("[DRLSynchronizer - \(self.managerType)] log.drl.sync - " + message)
    }
    
    private func log(_ progress: DRLProgress) {
        let from = progress.currentVersion
        let to = progress.requestedVersion
        let chunk = progress.currentChunk ?? DRLProgress.FIRST_CHUNK
        let chunks = progress.totalChunk ?? DRLProgress.FIRST_CHUNK
        log("downloading [\(from)->\(to)] \(chunk)/\(chunks)")
    }
}

extension DRLSynchronizer {
    
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
        switch self.managerType{
        case .IT:
            return DRLDataStorage.shared.lastFetch.timeIntervalSinceNow < -24 * 60 * 60
        case .EU:
            return DRLDataStorage.shared.lastFetchEU.timeIntervalSinceNow < -24 * 60 * 60
        }
    }
    
    var isFetchOutdatedAndAllowed: Bool {
        isSyncEnabled && isFetchOutdated
    }
    
}

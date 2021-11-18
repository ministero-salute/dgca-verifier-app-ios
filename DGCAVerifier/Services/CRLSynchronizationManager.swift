//
//  CRLSynchronizationManager.swift
//  Verifier
//
//  Created by Andrea Prosseda on 07/09/21.
//

import Foundation
import UIKit

protocol CRLSynchronizationDelegate {
    func statusDidChange(with result: CRLSynchronizationManager.Result)
}

class CRLSynchronizationManager {
    
    let AUTOMATIC_MAX_SIZE: Double = 5.0.fromMegaBytesToBytes
    
    enum Result {
        case downloadReady
        case downloading
        case completed
        case paused
        case error
        case statusNetworkError
    }
    
    static let shared = CRLSynchronizationManager()
    var firstRun: Bool = true
    var crlStatusFailCounter: Int {
        get {return _crlStatusFailCounter }
        set {_crlStatusFailCounter = newValue}
    }
    var crlFailCounter: Int {
        get {return _crlFailCounter }
        set {_crlFailCounter = newValue}
    }
    
    var progress: CRLProgress { _progress }
    var gateway: GatewayConnection { GatewayConnection.shared }
    
    private var delegate: CRLSynchronizationDelegate?
    private var timer: Timer?
    
    private var isDownloadingCRL: Bool = false
    
    private var _serverStatus: CRLStatus?
    private var _progress: CRLProgress
    {
        get { CRLDataStorage.shared.progress ?? .init() }
        set { CRLDataStorage.shared.saveProgress(newValue) }
    }
    private var _crlStatusFailCounter: Int = 1
    private var _crlFailCounter: Int = 1
    
    func initialize(delegate: CRLSynchronizationDelegate?) {
        guard isSyncEnabled else { return }
        log("initialize")
        self.delegate = delegate
        setTimer() { self.start() }
        crlFailCounter = LocalData.getSetting(from: Constants.drlMaxRetries)?.intValue ?? 1
    }
    
    func start() {
        log("check status")
        gateway.revocationStatus(progress) { (serverStatus, error, responseCode) in
            guard error == nil, responseCode == 200 else {
                self.crlStatusFailCounter -= 1
                
                if self.crlStatusFailCounter < 0 || !Connectivity.isOnline || responseCode == 408 {
                    self.delegate?.statusDidChange(with: .statusNetworkError)
                }
                else {
                    self.cleanAndRetry()
                }
                
                return
            }
            
            self.crlStatusFailCounter = LocalData.getSetting(from: Constants.drlMaxRetries)?.intValue ?? 1
            self._serverStatus = serverStatus
            self.synchronize()
        }
    }
    
    var isSyncEnabled: Bool {
        LocalData.getSetting(from: "DRL_SYNC_ACTIVE")?.boolValue ?? true
    }
    
    private func synchronize() {
        log("start synchronization")
        guard outdatedVersion else { return downloadCompleted() }
        guard noPendingDownload else { return resumeDownload() }
        checkDownload()
    }
        
    func checkDownload() {
        _progress = CRLProgress(serverStatus: _serverStatus)
        guard !requireUserInteraction else { return showCRLUpdateAlert() }
        startDownload()
    }
    
    func startDownload() {
        guard Connectivity.isOnline else {
            self.showNoConnectionAlert()
            return
        }
        
        isDownloadingCRL = true
        download()
    }
    
    func resumeDownload() {
        log("resuming previous progress")
        guard sameChunkSize else { return cleanAndRetry() }
        guard sameRequestedVersion else { return cleanAndRetry() }
        guard oneChunkAlreadyDownloaded else { return readyToDownload() }
        readyToResume()
    }
    
    func readyToDownload() {
        log("user can download")
        delegate?.statusDidChange(with: .downloadReady)
    }
    
    func readyToResume() {
        log("user can resume download")
        delegate?.statusDidChange(with: .paused)
    }
    
    func downloadCompleted() {
        log("download completed")
        guard sameDatabaseSize else {
            log("inconsistent number of UCVI, clean needed")
            CRLSynchronizationManager.shared.crlFailCounter -= 1
            if CRLSynchronizationManager.shared.crlFailCounter < 0 {
                log("failed too many times")
                if progress.remainingSize == "0.00" || progress.remainingSize == "" {
                    delegate?.statusDidChange(with: .statusNetworkError)
                } else {
                    delegate?.statusDidChange(with: .error)
                }
                clean()
                return
            }
            else {
                log("retrying...")
                return cleanAndRetry()
            }
        }
        completeProgress()
        _serverStatus = nil
        crlFailCounter = LocalData.getSetting(from: Constants.drlMaxRetries)?.intValue ?? 1
        CRLDataStorage.shared.lastFetch = Date()
        isDownloadingCRL = false
        delegate?.statusDidChange(with: .completed)
    }
    
    func clean() {
        _progress = .init()
        _serverStatus = nil
        isDownloadingCRL = false
        CRLDataStorage.clear()
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
        delegate?.statusDidChange(with: .downloading)
        gateway.updateRevocationList(progress) { crl, error, statusCode in
            guard statusCode == 200 else { return self.handleDRLHTTPError(statusCode: statusCode) }
            guard error == nil else { return self.errorFlow() }
            guard let crl = crl else { return self.errorFlow() }
            self.manageResponse(with: crl)
        }
    }
    
    private func manageResponse(with crl: CRL) {
        guard isConsistent(crl) else { return cleanAndRetry() }
        log("managing response")
        CRLDataStorage.store(crl: crl)
        updateProgress(with: crl.sizeSingleChunkInByte)
        startDownload()
    }
    
    private func handleDRLHTTPError(statusCode: Int?) {
        guard let statusCode = statusCode else {
            return self.cleanAndRetry()
        }

        switch statusCode {
        case 400...407:
            self.cleanAndRetry()
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
        self.isDownloadingCRL = false
        delegate?.statusDidChange(with: .error)
    }
        
    private func updateProgress(with size: Int?) {
        let current = progress.currentChunk ?? CRLProgress.FIRST_CHUNK
        let downloadedSize = progress.downloadedSize ?? 0
        _progress.currentChunk = current + 1
        _progress.downloadedSize = downloadedSize + (size?.doubleValue ?? 0)
    }
    
    private func completeProgress() {
        let completedVersion = progress.requestedVersion
        _progress = .init(version: completedVersion)
    }
    
    public func showCRLUpdateAlert() {
        let content: AlertContent = .init(
            title: "crl.update.alert.title".localizeWith(progress.remainingSize),
            message: "crl.update.message".localizeWith(progress.remainingSize),
            confirmAction: { self.startDownload() },
            confirmActionTitle: "crl.update.download.now",
            cancelAction: { self.readyToDownload() },
            cancelActionTitle: "crl.update.try.later"
        )

        UIApplication.showAppAlert(content: content)
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

}

extension CRLSynchronizationManager {
    
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
        return currentChunk > CRLProgress.FIRST_CHUNK
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

    private func isConsistent(_ crl: CRL) -> Bool {
        guard let crlVersion = crl.version else { return false }
        return crlVersion == progress.requestedVersion
    }
    
    var sameDatabaseSize: Bool {
        guard let serverStatus = _serverStatus, let serverTotalNumberUCVI = serverStatus.totalNumberUCVI else {return false}
        return serverTotalNumberUCVI == CRLDataStorage.crlTotalNumber()
    }
    
    private func log(_ message: String) {
        print("log.crl.sync - " + message)
    }
    
    private func log(_ progress: CRLProgress) {
        let from = progress.currentVersion
        let to = progress.requestedVersion
        let chunk = progress.currentChunk ?? CRLProgress.FIRST_CHUNK
        let chunks = progress.totalChunk ?? CRLProgress.FIRST_CHUNK
        log("downloading [\(from)->\(to)] \(chunk)/\(chunks)")
    }
}

extension CRLSynchronizationManager {
    
    func setTimer(completion: (()->())? = nil) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            self.trigger(completion: completion)
        }
        timer?.tolerance = 5.0
        self.trigger(completion: completion)
    }
    
    func trigger(completion: (()->())? = nil) {
        guard (isFetchOutdatedAndAllowed || firstRun) && !isDownloadingCRL else { return }
        firstRun = false
        completion?()
    }
    
    var isFetchOutdated: Bool {
        CRLDataStorage.shared.lastFetch.timeIntervalSinceNow < -24 * 60 * 60
    }
    
    var isFetchOutdatedAndAllowed: Bool {
        isSyncEnabled && CRLDataStorage.shared.lastFetch.timeIntervalSinceNow < -24 * 60 * 60
    }

}

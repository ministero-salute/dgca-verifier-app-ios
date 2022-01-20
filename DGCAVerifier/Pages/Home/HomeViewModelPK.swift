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
//  HomeViewModelPK.swift
//  Verifier
//
//  Created by Emilio Apuzzo on 20/01/22.
//

import Foundation
import PromiseKit

class HomeViewModelPK {
    
    public enum Result {
        case updateComplete
        case versionOutdated
        case error(String)
    }
    
    public enum ScanStatus {
        case versionOutdated
        case certFetchOutdated
        case drlFetchOutdated
        case drlDownloadNotCompleted
        case scanModeUnset
        case canScan
    }
    
    let results: Observable<Result> = Observable(nil)
    let isLoading: Observable<Bool> = Observable(true)
    let isScanEnabled: Observable<Bool> = Observable(false)
    let syncStatus: Observable<DRLSynchronizationManager.Result> = Observable(nil)
    var dispatchGroupErrors: [String] = .init()
    let sync: DRLSynchronizationManager = DRLSynchronizationManager.shared

    public func startOperations() {
        isLoading.value = true
        GatewayConnection.shared.initialize { [weak self] in self?.load() }
    }
    
    public func loadComplete(updateLastFetch: Bool) {
        results.value = .updateComplete
        isLoading.value = false
        
        // Initialize DRLSynchronizationManager
        self.sync.initialize(delegate: self)
        
        Store.set(false, for: .isTorchActive)
        
        if updateLastFetch {
            LocalData.sharedInstance.lastFetch = Date()
            LocalData.sharedInstance.save()
        }
        
        print("log.upload.complete")
    }
    
    public func getLastUpdate() -> Date? {
        let lastFetch = LocalData.sharedInstance.lastFetch
        return lastFetch.timeIntervalSince1970 > 0 ? lastFetch : nil
    }
    
    private func checkCurrentVersion() {
        guard !isVersionOutdated() else { return }
        results.value = .versionOutdated
    }
    
    public func isVersionOutdated() -> Bool {
        guard let version = currentVersion() else { return false }
        guard let minVersion = minVersion() else { return false }
        return version.compare(minVersion, options: .numeric) == .orderedAscending
    }
    
    public func currentVersion() -> String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    public func isScanMode2G() -> Bool {
        return Store.getBool(key: .isScanMode2G)
    }
    
    public func isScanModeSet() -> Bool {
        return Store.getBool(key: .isScanModeSet)
    }
    
    public func isAppReadyToScan() -> ScanStatus {
        if self.isVersionOutdated() { return .versionOutdated }
                
        let certFetch                   = LocalData.sharedInstance.lastFetch.timeIntervalSince1970
        let certFetchUpdated            = certFetch > 0
        
        let drlFetchOutdated            = DRLSynchronizationManager.shared.isFetchOutdated
        
        let isDRLDownloadCompleted      = DRLDataStorage.shared.isDRLDownloadCompleted
        let isDRLAllowed                = DRLSynchronizationManager.shared.isSyncEnabled
        
        guard self.isScanModeSet() else { return .scanModeUnset }
        
        if !certFetchUpdated { return .certFetchOutdated }
        if !isDRLAllowed { return .canScan }
        if drlFetchOutdated { return .drlFetchOutdated }
        if !isDRLDownloadCompleted { return .drlDownloadNotCompleted }
        
        return .canScan
    }
    
    public func isConnectionAvailable() -> Bool {
        return Connectivity.isOnline
    }
    
    public func startSync() {
        if self.sync.noPendingDownload || sync.needsServerStatusUpdate {
            sync.start()
        } else {
            sync.download()
        }
    }
    
    // Note: was sync.download(), need to test
    public func startDownloading() -> Void {
        sync.startDownload()
    }
    
    // Note: not the model's responsibility
    public func readyToDownload() -> Void {
        self.sync.readyToDownload()
    }
    
    public func getDRLProgress() -> DRLProgress {
        return self.sync.progress
    }
    
    private func minVersion() -> String? {
        return SettingDataStorage
            .sharedInstance
            .settings
            .first(where: { $0.name == "ios" && $0.type == "APP_MIN_VERSION" })?
            .value
    }

}

extension HomeViewModelPK: DRLSynchronizationDelegate {
    func statusDidChange(with result: DRLSynchronizationManager.Result) {
        self.syncStatus.value = result
    }
}

extension HomeViewModelPK {
    
    private func load() {
        firstly {
            when(fulfilled: loadSettings(), loadCertificates(), loadRevocationList())
        }.done { result1, result2, result3 in
            self.loadComplete(updateLastFetch: true)
        }.catch { error in
            self.loadComplete(updateLastFetch: false)
        }
    }
    
    private func loadSettings() -> Promise<Void> {
        return SettingDataStorage.initialize()
    }
    
    private func loadCertificates() -> Promise<Void> {
        return LocalData.initialize()
    }
    
    private func loadRevocationList() -> Promise<Void> {
        return DRLDataStorage.initialize()
    }

}

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
//  Created by Emilio Apuzzo on 21/04/22.
//

import Foundation
import UIKit
import SwiftDGC
import SwiftyJSON

enum SynchronizationContext {
    case IT
    case EU
    case ALL
    case NONE
}

enum SyncManagerType {
    case IT
    case EU
}

protocol DRLSynchronizationDelegate {
    func statusDidChange(with result: DRLSynchronizationManager.Status, progress: DRLTotalProgress)
    func showDRLUpdateAlert()
}

protocol DRLSynchronizerDelegate {
    func signalDownloadCompleted(managerType: SyncManagerType)
    func statusDidChange(managerType: SyncManagerType)
}

class DRLSynchronizationManager {
    
    static let shared = DRLSynchronizationManager()
    
    private lazy var ITSync: DRLSynchronizer = DRLSynchronizer(managerType: .IT)
    private lazy var EUSync: DRLSynchronizer = DRLSynchronizer(managerType: .EU)
    var progress: DRLTotalProgress!
    
    private var homeViewControllerDelegate: DRLSynchronizationDelegate?
        
    enum Status {
        case downloadReady
        case downloading
        case completed
        case paused
        case error
        case statusNetworkError
        case userInteractionRequired
    }
    
    func initialize(delegate: DRLSynchronizationDelegate?) {
        self.homeViewControllerDelegate = delegate
        
        self.initializeSynchronizers()
        
        self.progress = DRLTotalProgress(progressAccessors: self.getProgressAccessors)
    }
    
    func initializeSynchronizers() {
        switch self.synchronizationContext {
            case .IT:
                self.ITSync.initialize(delegate: self)
            case .EU:
                self.EUSync.initialize(delegate: self)
            case .ALL:
                self.ITSync.initialize(delegate: self)
                self.EUSync.initialize(delegate: self)
            case .NONE:
                break
        }
    }
    
    var isSyncEnabled: Bool {
        LocalData.getSetting(from: "DRL_SYNC_ACTIVE")?.boolValue ?? true
    }
    
    var isFetchOutdated: Bool {
        switch self.synchronizationContext {
            case .IT:
                return ITSync.isFetchOutdated
            case .EU:
                return EUSync.isFetchOutdated
            case .ALL:
                return ITSync.isFetchOutdated && EUSync.isFetchOutdated
            case .NONE:
                return false
        }
    }
    
    private var synchronizationContext: SynchronizationContext{
        #if DEBUG
            return .ALL
        #else
        
        let settings = SettingDataStorage.sharedInstance
        let syncStatusIT = settings.getFirstSetting(withName: Constants.synchronizationStatusIT)?
            .boolValue ?? false
        let syncStatusEU = settings.getFirstSetting(withName: Constants.synchronizationStatusEU)?
            .boolValue ?? false
        
        if syncStatusIT && syncStatusEU {
            return .ALL
        }
        
        else if syncStatusIT {
            return .IT
        }
        
        else if syncStatusEU {
            return .EU
        }
        
        return .NONE
        #endif
    }
    
    private var getProgressAccessors: [ProgressAccessor] {
        switch self.synchronizationContext {
            case .IT:
                return [{ return self.ITSync.progress }]
            case .EU:
                return [{ return self.EUSync.progress }]
            case .ALL:
                return [{ return self.ITSync.progress }, { return self.EUSync.progress }]
            case .NONE:
                return []
        }
    }
    
    public func start() {
        switch synchronizationContext {
        case .IT:
            ITSync.start()
        case .EU:
            EUSync.start()
        case .ALL:
            ITSync.start()
            EUSync.start()
        case .NONE:
            break
        }
    }
    
    
    public func download() {
        switch synchronizationContext {
        case .IT:
            ITSync.download()
        case .EU:
            EUSync.download()
        case .ALL:
            ITSync.download()
            EUSync.download()
        case .NONE:
            break
        }
    }
    
    func startDownload() {
        switch synchronizationContext {
        case .IT:
            ITSync.startDownload()
        case .EU:
            EUSync.startDownload()
        case .ALL:
            ITSync.startDownload()
            EUSync.startDownload()
        case .NONE:
            break
        }
    }
    
    func readyToDownload() {
        switch synchronizationContext {
        case .IT:
            ITSync.readyToDownload()
        case .EU:
            EUSync.readyToDownload()
        case .ALL:
            ITSync.readyToDownload()
            EUSync.readyToDownload()
        case .NONE:
            break
        }
    }
    
    func signalProgressCompletion(managerType: SyncManagerType){
        if managerType == .IT {
            ITSync.completeProgress()
            if synchronizationContext == .IT{
                homeViewControllerDelegate?.statusDidChange(with: .completed, progress: self.progress)
            }
            if synchronizationContext == .ALL && EUSync.syncCompleted{
                homeViewControllerDelegate?.statusDidChange(with: .completed, progress: self.progress)
            }
        }
        else if managerType == .EU {
            EUSync.completeProgress()
            if synchronizationContext == .EU{
                homeViewControllerDelegate?.statusDidChange(with: .completed, progress: self.progress)
            }
            if synchronizationContext == .ALL && ITSync.syncCompleted{
                homeViewControllerDelegate?.statusDidChange(with: .completed, progress: self.progress)
            }
        }
    }
    
    public var needsServerStatusUpdate: Bool {
        let needsServerStatusUpdateIT = ITSync.needsServerStatusUpdate
        let needsServerStatusUpdateEU = EUSync.needsServerStatusUpdate
        return (needsServerStatusUpdateIT && needsServerStatusUpdateEU)
    }
    
    public var noPendingDownload: Bool {
        let noPendingDownloadIT = ITSync.noPendingDownload
        let noPendingDownloadEU = EUSync.noPendingDownload
        return (noPendingDownloadIT && noPendingDownloadEU)
    }
    
    private var outdatedVersion: Bool {
        let outdatedVersionIT = ITSync.outdatedVersion
        let outdatedVersionEU = EUSync.outdatedVersion
        return (outdatedVersionIT && outdatedVersionEU)
    }
    
    private var sameRequestedVersion: Bool {
        let sameRequestedVersionIT = ITSync.sameRequestedVersion
        let sameRequestedVersionEU = EUSync.sameRequestedVersion
        return (sameRequestedVersionIT && sameRequestedVersionEU)
    }
}

extension DRLSynchronizationManager: DRLSynchronizerDelegate {
    
    func signalDownloadCompleted(managerType: SyncManagerType) {
        self.signalProgressCompletion(managerType: managerType)
    }
    
    func statusDidChange(managerType: SyncManagerType) {
        switch synchronizationContext{
        case .IT:
            guard let ITSyncStatus = ITSync.syncStatus else { return }
            self.homeViewControllerDelegate?.statusDidChange(with: ITSyncStatus, progress: self.progress)
            return
        case .EU:
            guard let EUSyncStatus = EUSync.syncStatus else { return }
            self.homeViewControllerDelegate?.statusDidChange(with: EUSyncStatus, progress: self.progress)
            return
        case .ALL:
            handleSyncStatus(managerType: managerType)
            return
        case .NONE:
            return
        }
    }
    
    private func handleSyncStatus(managerType: SyncManagerType){
        
        guard let ITSyncStatus = ITSync.syncStatus, let EUSyncStatus = EUSync.syncStatus else {
            return
        }

        if (ITSyncStatus == .userInteractionRequired && EUSyncStatus == .userInteractionRequired) {
            self.homeViewControllerDelegate?.statusDidChange(with: .userInteractionRequired, progress: self.progress)
            return
        }

        if ITSyncStatus == .statusNetworkError || EUSyncStatus == .statusNetworkError {
            self.homeViewControllerDelegate?.statusDidChange(with: .statusNetworkError, progress: self.progress)
            return
        }
        if ITSyncStatus == .error || EUSyncStatus == .error {
            if ITSyncStatus == .downloading || EUSyncStatus == .downloading {
                self.homeViewControllerDelegate?.statusDidChange(with: .statusNetworkError, progress: self.progress)
            }
            else {
                self.homeViewControllerDelegate?.statusDidChange(with: .error, progress: self.progress)
            }
            return
        }
        if ITSyncStatus == .downloadReady || EUSyncStatus == .downloadReady {
            self.homeViewControllerDelegate?.statusDidChange(with: .downloadReady, progress: self.progress)
            return
        }
        if ITSyncStatus == .paused || EUSyncStatus == .paused {
            self.homeViewControllerDelegate?.statusDidChange(with: .paused, progress: self.progress)
            return
        }
        if ITSyncStatus == .downloading || EUSyncStatus == .downloading {
            self.homeViewControllerDelegate?.statusDidChange(with: .downloading, progress: self.progress)
            return
        }
        if ITSyncStatus == .completed && EUSyncStatus == .completed {
            self.homeViewControllerDelegate?.statusDidChange(with: .completed, progress: self.progress)
            return
        }
    }
}

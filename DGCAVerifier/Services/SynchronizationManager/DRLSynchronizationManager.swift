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
    func statusDidChange(with result: DRLSynchronizationManager.Result)
}

class DRLSynchronizationManager {
    
    static let shared = DRLSynchronizationManager()
    
    private var ITSync: DRLITSynchronizationManager
    private var EUSync: DRLEUSynchronizationManager
    var progress: DRLTotalProgress
    
    private var delegate: DRLSynchronizationDelegate?
    
    enum Result {
        case downloadReady
        case downloading
        case completed
        case paused
        case error
        case statusNetworkError
    }
    
    func initialize(delegate: DRLSynchronizationDelegate?) {
        self.delegate = delegate
        
        ITSync.initialize(delegate: delegate)
        EUSync.initialize(delegate: delegate)
    }

    init(){
        ITSync = DRLITSynchronizationManager.shared
        EUSync = DRLEUSynchronizationManager.shared
        progress = DRLTotalProgress()
    }
    
    var isSyncEnabled: Bool {
        LocalData.getSetting(from: "DRL_SYNC_ACTIVE")?.boolValue ?? true
    }
    
    var isFetchOutdated: Bool {
        return ITSync.isFetchOutdated && EUSync.isFetchOutdated
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
            if synchronizationContext == .IT{
                ITSync.completeProgress()
            }
            if synchronizationContext == .ALL && !EUSync.chunksNotYetCompleted {
                EUSync.completeProgress()
                ITSync.completeProgress()
            }
        }
        else if managerType == .EU {
            if synchronizationContext == .EU{
                EUSync.completeProgress()
            }
            if synchronizationContext == .ALL && !ITSync.chunksNotYetCompleted {
                EUSync.completeProgress()
                ITSync.completeProgress()
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
    
    public func showDRLUpdateAlert() {
        let totalRemainingSize = ITSync.progress.remainingSize + EUSync.progress.remainingSize
        let content: AlertContent = .init(
            title: "drl.update.alert.title".localizeWith(totalRemainingSize),
            message: "drl.update.message".localizeWith(totalRemainingSize),
            confirmAction: { self.startDownload()},
            confirmActionTitle: "drl.update.download.now",
            cancelAction: { self.readyToDownload()},
            cancelActionTitle: "drl.update.try.later"
        )

        UIApplication.showAppAlert(content: content)
    }
}

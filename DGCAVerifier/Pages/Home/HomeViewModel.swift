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
//  HomeViewModel.swift
//  verifier-ios
//
//

import Foundation

class HomeViewModel {
    
    public enum Result {
        case initializeSync
        case updateComplete
        case versionOutdated
        case error(String)
    }
    
    let results: Observable<Result>     = Observable(nil)
    let isLoading: Observable<Bool>     = Observable(true)
    var dispatchGroupErrors: [String]   = .init()
    
    public func startOperations() {
        isLoading.value = true
        GatewayConnection.shared.initialize { [weak self] in self?.load() }
    }
    
    public func loadComplete(updateLastFetch: Bool) {
        results.value = .updateComplete
        isLoading.value = false
        results.value = .initializeSync
        
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
    
    private func minVersion() -> String? {
        return SettingDataStorage
            .sharedInstance
            .settings
            .first(where: { $0.name == "ios" && $0.type == "APP_MIN_VERSION" })?
            .value
    }

}

extension HomeViewModel {
    
    private func load() {
        let group = DispatchGroup()
        
        loadSettings(in: group)
        loadCertificates(in: group)
        loadRevocationList(in: group)
        
        group.notify(queue: .main) { [weak self] in
            if self?.dispatchGroupErrors.count == 0 {
                self?.loadComplete(updateLastFetch: true)
            } else {
                self?.loadComplete(updateLastFetch: false)
            }
        }
    }
    
    private func loadSettings(in loadingGroup: DispatchGroup) {
        SettingDataStorage.initialize {
            GatewayConnection.shared.settings { [weak self] error in
                if error == nil {
                    print("log.settings.done")
                } else {
                    self?.dispatchGroupErrors.append(error!)
                    print("log.settings.error")
                }
                
                loadingGroup.leave()
            }
        }
        loadingGroup.enter()
    }
    
    private func loadCertificates(in loadingGroup: DispatchGroup) {
        LocalData.initialize {
            GatewayConnection.shared.update { [weak self] error in
                if error == nil {
                    print("log.keys.done")
                } else {
                    self?.dispatchGroupErrors.append(error!)
                    print("log.keys.error")
                }
                
                loadingGroup.leave()
            }
        }
        loadingGroup.enter()
    }

    private func loadRevocationList(in loadingGroup: DispatchGroup) {
        CRLDataStorage.initialize {
            print("log.crl.done")
            loadingGroup.leave()
        }
        loadingGroup.enter()
    }

}

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
//  SettingDataStorage.swift
//  Verifier
//
//  Created by Andrea Prosseda on 27/07/21.
//

import Foundation
import SwiftDGC
import SwiftyJSON

struct SettingDataStorage: Codable {
    static var sharedInstance = SettingDataStorage()
    
    var settings = [Setting]()

    mutating func addOrUpdateSettings(_ setting: Setting) {
        if let i = settings.firstIndex(where: { $0.name == setting.name && $0.type == setting.type }) {
            settings[i].value = setting.value
            return
        }
        settings = settings + [setting]
    }
    
    func getFirstSetting(withName name: String) -> String? {
        return settings.filter{ $0.name == name}.first?.value
    }
    
    public func save() {
        Self.storage.save(self, completion: { _ in })
    }
    
    static let storage = SecureStorage<SettingDataStorage>(fileName: "setting_secure")
    
    static func initialize(completion: @escaping () -> Void) {
        storage.loadStoredData(fallback: SettingDataStorage.sharedInstance) { success in
            guard let result = success else {
                return
            }
            let format = l10n("log.settings")
            print(String.localizedStringWithFormat(format, result.settings.count))
            SettingDataStorage.sharedInstance = result
            completion()
        }
        CoreManager.publicKeyEncoder = LocalDataDelegate.instance
    }
}


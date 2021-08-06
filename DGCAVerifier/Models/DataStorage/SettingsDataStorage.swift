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
        Self.storage.save(self)
    }
    
    static let storage = SecureStorage<SettingDataStorage>(fileName: "setting_secure")
    
    static func initialize(completion: @escaping () -> Void) {
        storage.loadOverride(fallback: SettingDataStorage.sharedInstance) { success in
            guard let result = success else {
                return
            }
            let format = l10n("log.settings")
            print(String.localizedStringWithFormat(format, result.settings.count))
            SettingDataStorage.sharedInstance = result
            completion()
        }
        HCert.publicKeyStorageDelegate = LocalDataDelegate.instance
    }
}


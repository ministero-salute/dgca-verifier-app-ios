//
//  GatewayConnection+Settings.swift
//  Verifier
//
//  Created by Andrea Prosseda on 27/07/21.
//

import Foundation
import SwiftDGC

extension GatewayConnection {
    
    private var settingsUrl: String { baseUrl + "settings" }
    
    func settings(completion: ((String?) -> Void)? = nil) {
        getSettings { settings in
            guard let settings = settings else {
                completion?("server.error.generic.error".localized)
                return
            }
            
            for setting in settings {
                SettingDataStorage.sharedInstance.addOrUpdateSettings(setting)
            }
            SettingDataStorage.sharedInstance.save()
            
            completion?(nil)
        }
    }
    
    private func getSettings(completion: (([Setting]?) -> Void)?) {
        session.request(settingsUrl).response {
            let decoder = JSONDecoder()
            let data = try? decoder.decode([Setting].self, from: $0.data ?? .init())
            guard let settings = data else {
                completion?(nil)
                return
            }
            completion?(settings)
        }
    }

}

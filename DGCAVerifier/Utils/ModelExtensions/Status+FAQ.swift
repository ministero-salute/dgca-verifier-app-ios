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
//  Status-FAQ.swift
//  Verifier
//
//  Created by Emilio Apuzzo on 23/02/22.
//

import Foundation

extension Status {
    
    var faqSettingsTitle: String? {
        let settingsDS = SettingDataStorage.sharedInstance

        switch self {
        case .valid:                    return settingsDS.getFirstSetting(withName: Constants.validFaqText)
        case .notValid:                 return settingsDS.getFirstSetting(withName: Constants.notValidFaqText)
        case .expired:                  return settingsDS.getFirstSetting(withName: Constants.notValidFaqText)
        case .notValidYet:              return settingsDS.getFirstSetting(withName: Constants.notValidYetFaqText)
        case .notGreenPass:             return settingsDS.getFirstSetting(withName: Constants.notDGCFaqText)
        case .revokedGreenPass:         return settingsDS.getFirstSetting(withName: Constants.notValidFaqText)
        case .verificationIsNeeded:     return settingsDS.getFirstSetting(withName: Constants.verificationNeededFaqText)
        }
    }
    
    var faqSettingsLink: String? {
        let settingsDS = SettingDataStorage.sharedInstance

        switch self {
        case .valid:                    return settingsDS.getFirstSetting(withName: Constants.validFaqLink)
        case .notValid:                 return settingsDS.getFirstSetting(withName: Constants.notValidFaqLink)
        case .expired:                  return settingsDS.getFirstSetting(withName: Constants.notValidFaqLink)
        case .notValidYet:              return settingsDS.getFirstSetting(withName: Constants.notValidYetFaqLink)
        case .notGreenPass:             return settingsDS.getFirstSetting(withName: Constants.notDGCFaqLink)
        case .revokedGreenPass:         return settingsDS.getFirstSetting(withName: Constants.notValidFaqLink)
        case .verificationIsNeeded:     return settingsDS.getFirstSetting(withName: Constants.verificationNeededFaqLink)
        }
    }
    
}

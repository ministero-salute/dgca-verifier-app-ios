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
//  ScanMode+UI.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 03/02/22.
//

import Foundation

extension ScanMode {
    
    var pickerOptionName: String {
        switch self {
        case .base:
            return "home.scan.picker.mode.3G".localized
        case .italyEntry:
            return "home.scan.picker.mode.italy.entry".localized
        case .reinforced:
            return "home.scan.picker.mode.2G".localized
        case .booster:
            return "home.scan.picker.mode.Booster".localized
        }
    }
    
    var associatedPickerDescriptionScanMode: String? {
        switch self {
        case .base:
            return SettingDataStorage.sharedInstance.getFirstSetting(withName: Constants.scanModeDescription3G)
        case .italyEntry:
            return SettingDataStorage.sharedInstance.getFirstSetting(withName: Constants.scanModeDescriptionItalyEntry)
        case .reinforced:
            return SettingDataStorage.sharedInstance.getFirstSetting(withName: Constants.scanModeDescription2G)
        case .booster:
            return SettingDataStorage.sharedInstance.getFirstSetting(withName: Constants.scanModeDescriptionBooster)
        }
    }
    
    var buttonTitleBoldName: String {
        switch self {
        case .base:
            return "home.scan.button.bold.3G".localized
        case .italyEntry:
            return "home.scan.button.bold.italy.entry".localized
        case .reinforced:
            return "home.scan.button.bold.2G".localized
        case .booster:
            return "home.scan.button.bold.Booster".localized
        }
    }
    
    var buttonTitleName: String {
        switch self {
        case .base:
            return "home.scan.button.mode.3G".localized
        case .italyEntry:
            return "home.scan.button.mode.italy.entry".localized
        case .reinforced:
            return "home.scan.button.mode.2G".localized
        case .booster:
            return "home.scan.button.mode.Booster".localized
        }
    }
    
}

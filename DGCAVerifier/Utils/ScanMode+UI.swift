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
        }
    }
    
    var associatedPickerDescriptionScanMode: String? {
        switch self {
        case .base:
            return SettingDataStorage.sharedInstance.getFirstSetting(withName: Constants.scanModeDescription3G)
        }
    }
    
    var buttonTitleBoldName: String {
        switch self {
        case .base:
            return "home.scan.button.bold.3G".localized
        }
    }
    
    var buttonTitleName: String {
        switch self {
        case .base:
            return "home.scan.button.mode.3G".localized
        }
    }
    
}

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
//  Status+Configuration.swift
//  Verifier
//
//  Created by Andrea Prosseda on 26/07/21.
//

import UIKit

extension Status {
    
    var backgroundColor: UIColor {
        switch self {
        case .valid:
            return Palette.green
        case .verificationIsNeeded:
            return Palette.orange
        default:
            return Palette.red
        }
    }
    
    var mainImage: UIImage? {
        switch self {
        case .valid:                return "icon_valid".image
        case .notValid:             return "icon_not-valid".image
        case .expired:                return "icon_not-valid".image
        case .notValidYet:          return "icon_not-valid-yet".image
        case .notGreenPass:         return "icon_not-green-pass".image
        case .revokedGreenPass:     return "icon_not-green-pass".image
        case .verificationIsNeeded: return "icon_need-verification".image
        }
    }
    
    var title: String {
        switch self {
        case .valid:                return "result.title.valid"
        case .notValid:             return "result.title.not.valid"
        case .expired:              return "result.title.expired"
        case .notValidYet:          return "result.title.not.valid.yet"
        case .notGreenPass:         return "result.title.not.green.pass"
        case .revokedGreenPass:     return "result.title.revoked.green.pass"
        case .verificationIsNeeded: return "result.title.need.verification"
            
        }
    }
    
    var secondScanTitle: String {
        switch self {
        case .valid:                return "result.second.scan.title.valid"
        case .notValidYet:          return "result.second.scan.title.not.valid"
        case .notValid:             return "result.second.scan.title.not.valid"
        case .expired:              return "result.second.scan.title.not.valid"
        case .revokedGreenPass:     return "result.second.scan.title.not.valid"
        case .verificationIsNeeded: return "result.second.scan.title.not.valid"
        case .notGreenPass:         return "result.title.not.green.pass"
        }
    }
    
    var description: String? {
        switch self {
        case .valid:                return "result.description.valid"
        case .notValidYet:          return "result.description.not.valid"
        case .notValid:             return "result.description.not.valid"
        case .expired:              return "result.description.not.valid"
        case .revokedGreenPass:     return "result.description.revoked"
        case .verificationIsNeeded: return "result.description.need.verification"
        default:                    return nil
        }
    }
    
    var showPersonalData: Bool {
        switch self {
        case .valid:                return true
        case .notValidYet:          return true
        case .notValid:             return true
        case .expired:              return true
        case .revokedGreenPass:     return true
        case .verificationIsNeeded: return true
        default:                    return false
        }
    }
    
    var showLastFetch: Bool {
        switch self {
        case .valid:                return true
        case .notValidYet:          return true
        case .notValid:             return true
        case .expired:             return true
        case .revokedGreenPass:     return true
        case .verificationIsNeeded: return true
        default:                    return false
        }
    }
    
    var showCountryName: Bool {
        switch self {
        case .valid:            return true
        default:                return false
        }
    }
    
    var isValidState: Bool {
        switch self {
        case .valid:            return true
        default:                return false
        }
    }
}

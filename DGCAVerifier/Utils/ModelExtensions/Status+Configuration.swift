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
        case .valid:            return Palette.green
        case .validPartially:   return Palette.green
        default:                return Palette.red
        }
    }
    
    var mainImage: UIImage? {
        switch self {
        case .valid:            return "icon_valid".image
        case .validPartially:   return "icon_valid".image
        case .notValid:         return "icon_not-valid".image
        case .notValidYet:      return "icon_not-valid-yet".image
        case .notGreenPass:     return "icon_not-green-pass".image
        }
    }
    
    var title: String {
        switch self {
        case .valid:            return "result.title.valid"
        case .validPartially:   return "result.title.valid.partially"
        case .notValid:         return "result.title.not.valid"
        case .notValidYet:      return "result.title.not.valid.yet"
        case .notGreenPass:     return "result.title.not.green.pass"
        }
    }
    
    var description: String? {
        switch self {
        case .valid:            return "result.description.valid"
        case .validPartially:   return "result.description.valid"
        case .notValidYet:      return "result.description.not.valid"
        case .notValid:         return "result.description.not.valid"
        default:                return nil
        }
    }
    
    var showPersonalData: Bool {
        switch self {
        case .valid:            return true
        case .validPartially:   return true
        case .notValidYet:      return true
        case .notValid:         return true
        default:                return false
        }
    }
    
    var showLastFetch: Bool {
        switch self {
        case .valid:            return true
        case .validPartially:   return true
        case .notValidYet:      return true
        case .notValid:         return true
        default:                return false
        }
    }
    
    var showCountryName: Bool {
        switch self {
        case .valid:            return true
        default:                return false
        }
    }
    
    var faqs: [Link] {
        switch self {
        case .valid:            return [.whatCanBeDone]
        case .validPartially:   return [.whatCanBeDone]
        case .notValidYet:      return [.qrValidityRange]
        case .notValid:         return [.whyQrNotValid]
        case .notGreenPass:     return [.whichQrScan]
        }
    }
    
    var isValidState: Bool {
        switch self {
        case .valid:            return true
        case .validPartially:   return true
        default:                return false
        }
    }
}

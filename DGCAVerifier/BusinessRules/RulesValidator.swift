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
//  RulesValidator.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 26/06/21.
//

import Foundation
import SwiftDGC

struct RulesValidator: Validator {
    
    private enum ValidationType {
        case `internal`
        case european
    }
    
    private static let currentValidationType: ValidationType = .internal
    
    static func getStatus(from hCert: HCert) -> Status {
        guard !isRevoked(hCert) else {
            #if DEBUG
                return .revokedGreenPass
            #else
                return .notValid
            #endif
        }
        switch currentValidationType {
        case .internal:     return MedicalRulesValidator.getStatus(from: hCert)
        case .european:     return CertLogicValidator.getStatus(from:hCert)
        }
    }
        
    public static func isRevoked(_ hCert: HCert) -> Bool {
        guard CRLSynchronizationManager.shared.isSyncEnabled else { return false }
        let hash = hCert.getUVCI().sha256()
        guard !hash.isEmpty else { return false }
        return CRLDataStorage.contains(hash: hash)
    }
    
}

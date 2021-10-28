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
//  MedicalRulesValidator.swift
//  Verifier
//
//  Created by Andrea Prosseda on 28/07/21.
//

import Foundation
import SwiftDGC

struct MedicalRulesValidator: Validator {
        
    static func getStatus(from hCert: HCert) -> Status {
        let statementValidityCheck = StatementValidityCheck()
        guard !statementValidityCheck.isStatementBlacklisted(hCert) else { return .notValid }
        switch hCert.type {
        case .test:
            let testValidityCheck = TestValidityCheck()
            return testValidityCheck.isTestValid(hCert)
        case .vaccine:
            let vaccineValidityCheck = VaccineValidityCheck()
            return vaccineValidityCheck.isVaccineDateValid(hCert)
        case .recovery:
            let recoveryValidityCheck = RecoveryValidityCheck()
            return recoveryValidityCheck.isRecoveryValid(hCert)
        case .unknown:
            return .notValid
        }
    }
    
    static func validate(_ current: Date, from validityStart: Date, to validityEnd: Date) -> Status {
        switch current {
        case ..<validityStart:
            return .notValidYet
        case validityStart...validityEnd:
            return .valid
        default:
            return .notValid
        }
    }
    
    static func validate(_ current: Date, from validityStart: Date, to validityEnd: Date, extendedTo validityEndExtension: Date) -> Status {
        switch current {
        case ..<validityStart:
            return .notValidYet
        case validityStart...validityEnd:
            return .valid
        case validityEnd...validityEndExtension:
            return .validPartially
        default:
            return .notValid
        }
    }
    
}

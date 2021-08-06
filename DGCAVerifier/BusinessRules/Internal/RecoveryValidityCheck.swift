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
//  RecoveryValidityCheck.swift
//  Verifier
//
//  Created by Davide Aliti on 21/05/21.
//

import Foundation
import SwiftDGC

struct RecoveryValidityCheck {
    
    typealias Validator = MedicalRulesValidator
    
    func isRecoveryValid(_ hcert: HCert) -> Status {
        guard let validFrom = hcert.recoveryDateFrom else { return .notValid }
        guard let validUntil = hcert.recoveryDateUntil else { return .notValid }
        
        guard let validityStart = validFrom.toRecoveryDate else { return .notValid }
        guard let validityEnd = validUntil.toRecoveryDate else { return .notValid }
    
        guard let currentDate = Date.startOfDay else { return .notValid }
        
        return Validator.validate(currentDate, from: validityStart, to: validityEnd)
    }
}

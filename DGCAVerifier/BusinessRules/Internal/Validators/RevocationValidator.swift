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
//  RevocationValidator.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 01/02/22.
//

import Foundation
import SwiftDGC

struct RevocationValidator: DGCValidator {
    
    func validate(hcert: HCert) -> Status {
        let shortStatus = shortValidate(hcert: hcert)
        let longStatus = longValidate(hcert: hcert)
        let shaValidationStatus = [shortStatus, longStatus]
        
        let failedValidations = shaValidationStatus.filter{ $0 != .valid }
        return failedValidations.isEmpty ? .valid : failedValidations.first!
    }
    
    func longValidate(hcert: HCert) -> Status {
        guard CRLSynchronizationManager.shared.isSyncEnabled else { return .valid }
        let hash = hcert.getUVCI().sha256()

        guard !hash.isEmpty else { return .valid }
        return CRLDataStorage.contains(hash: hash) ? .revokedGreenPass : .valid
    }
    
    func shortValidate(hcert: HCert) -> Status {
        guard CRLSynchronizationManager.shared.isSyncEnabled else { return .valid }
        let hash = hcert.getUVCI().shortSha256()
        
        guard !hash.isEmpty else { return .valid }
        return CRLDataStorage.contains(hash: hash) ? .revokedGreenPass : .valid
    }
    
}

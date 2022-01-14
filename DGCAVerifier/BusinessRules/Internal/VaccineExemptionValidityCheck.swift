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
//  VaccineExemptionValidityCheck.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 12/01/22.
//

import Foundation
import SwiftDGC

struct VaccineExemptionValidityCheck {
    
    typealias Validator = MedicalRulesValidator
    
    func isExemptionValid(_ hcert: HCert) -> Status {
        guard let exemption = hcert.vaccineExemptionStatements.last else { return .notValid }
        guard let dateFrom = exemption.dateFrom else { return .notValid }
        guard let currentDate = Date.startOfDay else { return .notValid }
        guard let dateUntil = exemption.dateUntil else {
            let validity = Validator.validate(currentDate, from: dateFrom)
            return isBoosterScanModeActive ? checkValidityOnBoosterScanMode(validity) : validity
        }
        let validity = Validator.validate(currentDate, from: dateFrom, to: dateUntil)
        return isBoosterScanModeActive ? checkValidityOnBoosterScanMode(validity) : validity
    }
    
    private var isBoosterScanModeActive: Bool {
        return Store.get(key: .scanMode) == Constants.scanModeBooster
    }
    
    private func checkValidityOnBoosterScanMode(_ certStatus: Status) -> Status {
        guard isBoosterScanModeActive, certStatus == .valid else { return certStatus }
        return .verificationIsNeeded
    }
        
}

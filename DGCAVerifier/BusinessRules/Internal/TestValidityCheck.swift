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
//  TestValidityCheck.swift
//  Verifier
//
//  Created by Davide Aliti on 21/05/21.
//

import Foundation
import SwiftDGC

struct TestValidityCheck {
    
    typealias Validator = MedicalRulesValidator
    
    private let rapidStartHoursKey = "rapid_test_start_hours"
    private let rapidEndHoursKey = "rapid_test_end_hours"
    private let molecularStartHoursKey = "molecular_test_start_hours"
    private let molecularEndHoursKey = "molecular_test_end_hours"
    
    func isTestNegative(_ hcert: HCert) -> Status {
        guard let isNegative = hcert.testNegative else { return .notValid }
        return isNegative ? .valid : .notValid
    }
    
    func isTestDateValid(_ hcert: HCert) -> Status {
        guard let isMolecularTest = hcert.isMolecularTest,
              let isRapidTest = hcert.isRapidTest else { return.notValid }
        let startHours: String?
        let endHours: String?
        if isMolecularTest {
            startHours = LocalData.getSetting(from: molecularStartHoursKey)
            endHours = LocalData.getSetting(from: molecularEndHoursKey)
        }
        else if isRapidTest {
            startHours = LocalData.getSetting(from: rapidStartHoursKey)
            endHours = LocalData.getSetting(from: rapidEndHoursKey)
        }
        else {
            return .notValid
        }
        guard let start = startHours?.intValue else { return .notGreenPass }
        guard let end = endHours?.intValue else { return .notGreenPass }

        guard let dateString = hcert.testDate else { return .notValid }
        guard let dateTime = dateString.toTestDate else { return .notValid }
        guard let validityStart = dateTime.add(start, ofType: .hour) else { return .notValid }
        guard let validityEnd = dateTime.add(end, ofType: .hour) else { return .notValid }
    
        return Validator.validate(Date(), from: validityStart, to: validityEnd)
    }
    
    func isTestValid(_ hcert: HCert) -> Status {
        let testValidityResults = [isTestNegative(hcert), isTestDateValid(hcert)]
        return testValidityResults.first(where: {$0 != .valid}) ?? .valid
    }
    
}

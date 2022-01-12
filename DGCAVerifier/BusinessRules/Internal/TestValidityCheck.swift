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
    
    func isTestDateValid(_ hcert: HCert) -> Status {
        guard hcert.isKnownTestType else { return .notValid }
        
        let startHours = getStartHours(for: hcert)
        let endHours = getEndHours(for: hcert)
        
        guard let start = startHours?.intValue else { return .notGreenPass }
        guard let end = endHours?.intValue else { return .notGreenPass }
        
        guard let dateString = hcert.testDate else { return .notValid }
        guard let dateTime = dateString.toTestDate else { return .notValid }
        guard let validityStart = dateTime.add(start, ofType: .hour) else { return .notValid }
        guard let validityEnd = dateTime.add(end, ofType: .hour) else { return .notValid }
    
        return Validator.validate(Date(), from: validityStart, to: validityEnd)
    }
    
    func isTestNegative(_ hcert: HCert) -> Status {
        guard let isNegative = hcert.testNegative else { return .notValid }
        return isNegative ? .valid : .notValid
    }
    
    func isTestValid(_ hcert: HCert) -> Status {
        let scanMode: String = Store.get(key: .scanMode) ?? ""
        guard scanMode != Constants.scanMode2G, scanMode != Constants.scanModeBooster else { return .notValid }
        let testValidityResults = [isTestNegative(hcert), isTestDateValid(hcert)]
        return testValidityResults.first(where: {$0 != .valid}) ?? .valid
    }
    
    func getStartHours(for hcert: HCert) -> String? {
        if (hcert.isMolecularTest) { return molecularStartHours }
        if (hcert.isRapidTest) { return rapidStartHours }
        return nil
    }
    
    func getEndHours(for hcert: HCert) -> String? {
        if (hcert.isMolecularTest) { return molecularEndHours }
        if (hcert.isRapidTest) { return rapidEndHours }
        return nil
    }
   
    func getValue(from key: String) -> String? {
        LocalData.getSetting(from: key)
    }
    
    var molecularStartHours: String? { getValue(from: Constants.molecularStartHoursKey) }
    var molecularEndHours: String? { getValue(from: Constants.molecularEndHoursKey) }
    var rapidStartHours: String? { getValue(from: Constants.rapidStartHoursKey) }
    var rapidEndHours: String? { getValue(from: Constants.rapidEndHoursKey) }
   
}

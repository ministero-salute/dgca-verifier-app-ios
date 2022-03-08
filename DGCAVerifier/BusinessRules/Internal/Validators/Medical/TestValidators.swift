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
//  TestValidators.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 01/02/22.
//

import Foundation
import SwiftDGC

class TestConcreteValidator: DGCValidator {
    
    func validate(_ current: Date, from validityStart: Date) -> Status {
        switch current {
        case ..<validityStart:
            return .notValidYet
        default:
            return .valid
        }
    }
    
    func validate(_ current: Date, from validityStart: Date, to validityEnd: Date) -> Status {
        switch current {
        case ..<validityStart:
            return .notValidYet
        case validityStart...validityEnd:
            return .valid
        default:
            return .expired
        }
    }

    func validate(_ current: Date, from validityStart: Date, to validityEnd: Date, extendedTo validityEndExtension: Date) -> Status {
        switch current {
        case ..<validityStart:
            return .notValidYet
        case validityStart...validityEnd:
            return .valid
        case validityEnd...validityEndExtension:
            return .verificationIsNeeded
        default:
            return .expired
        }
    }
    
    fileprivate func isTestDateValid(_ hcert: HCert) -> Status {
        guard hcert.isKnownTestType else { return .notValid }
        
        let startHours = getStartHours(for: hcert)
        let endHours = getEndHours(for: hcert)
        
        guard let start = startHours?.intValue else { return .notGreenPass }
        guard let end = endHours?.intValue else { return .notGreenPass }
        
        guard let dateString = hcert.testDate else { return .notValid }
        guard let dateTime = dateString.toTestDate else { return .notValid }
        guard let validityStart = dateTime.add(start, ofType: .hour) else { return .notValid }
        guard let validityEnd = dateTime.add(end, ofType: .hour) else { return .notValid }
    
        return self.validate(Date(), from: validityStart, to: validityEnd)
    }
    
    private func isTestNegative(_ hcert: HCert) -> Status {
        guard let isNegative = hcert.testNegative else { return .notValid }
        return isNegative ? .valid : .notValid
    }
    
    private func getStartHours(for hcert: HCert) -> String? {
        if (hcert.isMolecularTest) { return molecularStartHours }
        if (hcert.isRapidTest) { return rapidStartHours }
        return nil
    }
    
    private func getEndHours(for hcert: HCert) -> String? {
        if (VerificationState.shared.shouldValidateTestOnly() && ScanMode.fetchFromLocalSettings() == .booster) { return rapidEndHours }
        if (hcert.isMolecularTest) { return molecularEndHours }
        if (hcert.isRapidTest) { return rapidEndHours }
        return nil
    }
   
    private func getValue(from key: String) -> String? {
        LocalData.getSetting(from: key)
    }
    
    private var molecularStartHours: String? { getValue(from: Constants.molecularStartHoursKey) }
    private var molecularEndHours: String? { getValue(from: Constants.molecularEndHoursKey) }
    private var rapidStartHours: String? { getValue(from: Constants.rapidStartHoursKey) }
    private var rapidEndHours: String? { getValue(from: Constants.rapidEndHoursKey) }
    
    
    func validate(hcert: HCert) -> Status {
        let testValidityResults = [isTestNegative(hcert), isTestDateValid(hcert)]
        return testValidityResults.first(where: {$0 != .valid}) ?? .valid
    }
}

class TestBaseValidator: TestConcreteValidator {}

class TestReinforcedValidator: TestBaseValidator {
    
    override func validate(hcert: HCert) -> Status {
        let result = isTestDateValid(hcert)
        switch result {
        case .expired:
            return .expired
        case .notValidYet:
            return .notValidYet
        default:
            return .notValid
        }
    }
    
}

class TestBoosterValidator: TestReinforcedValidator {}

class TestSchoolValidator: TestReinforcedValidator {}

class TestWorkValidator: TestBaseValidator {
    
    override func validate(hcert: HCert) -> Status {
        let result = super.validate(hcert: hcert)
        guard result != .expired else { return .expired }
        guard result != .notValidYet else { return .notValidYet }
        guard !isOver50(hcert) else { return .notValid }
        return result
    }
    
    private func isOver50 (_ hcert: HCert) -> Bool {
        guard let age = hcert.age else { return false }
        return age >= 50
    }
    
}

class TestItalyEntryValidator: TestConcreteValidator {}

//
//  TestValidators.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 01/02/22.
//

import Foundation
import SwiftDGC

class TestBaseValidator: DGCValidator {
    
    private func isTestDateValid(_ hcert: HCert) -> Status {
        guard hcert.isKnownTestType else { return .notValid }
        
        let startHours = getStartHours(for: hcert)
        let endHours = getEndHours(for: hcert)
        
        guard let start = startHours?.intValue else { return .notGreenPass }
        guard let end = endHours?.intValue else { return .notGreenPass }
        
        guard let dateString = hcert.testDate else { return .notValid }
        guard let dateTime = dateString.toTestDate else { return .notValid }
        guard let validityStart = dateTime.add(start, ofType: .hour) else { return .notValid }
        guard let validityEnd = dateTime.add(end, ofType: .hour) else { return .notValid }
    
        return TestBaseValidator.validate(Date(), from: validityStart, to: validityEnd)
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

class TestReinforcedValidator: AlwaysNotValid {}

class TestBoosterValidator: AlwaysNotValid {}

class TestSchoolValidator: AlwaysNotValid {}

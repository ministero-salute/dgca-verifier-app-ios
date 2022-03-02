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
//  RecoveryValidators.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 01/02/22.
//

import Foundation
import SwiftDGC

struct RecoveryInfo {
    
    private var hcert: HCert!
    
    public var isCBIS: Bool {
        guard self.hcert.rcountryCode?.uppercased() == Constants.ItalyCountryCode.uppercased() else { return false }
        guard let signedCerficate = self.hcert.signedCerficate else { return false }
        let extendedKeyUsage = signedCerficate.extendedKeyUsage
        let validKeysUsages = extendedKeyUsage.filter{ $0 == Constants.OID_RECOVERY || $0 == Constants.OID_RECOVERY_ALT }
        return !validKeysUsages.isEmpty
    }
    
    public var isIT: Bool {
        return self.hcert.countryCode == Constants.ItalyCountryCode
    }
    
    var patientOver50: Bool {
        guard let age = self.hcert.age else { return false }
        return age >= 50
    }
    
    public static func from(hcert: HCert) -> RecoveryInfo {
        return RecoveryInfo(hcert: hcert)
    }
    
}

class RecoveryBaseValidator: DGCValidator {
    
    typealias Validator = RecoveryBaseValidator
    
    fileprivate var recoveryInfo: RecoveryInfo!
    
    func validate(hcert: HCert) -> Status {
        self.recoveryInfo = RecoveryInfo.from(hcert: hcert)
        
        guard let validityFrom = hcert.recoveryDateFrom?.toRecoveryDate else { return .notValid }
        guard let validityUntil = hcert.recoveryDateUntil?.toRecoveryDate else { return .notValid }

        guard let recoveryStartDays = getStartDays(from: hcert) else { return .notValid }
        guard let recoveryEndDays = getEndDays(from: hcert) else { return .notValid }
        
        guard let validityStart = validityFrom.add(recoveryStartDays, ofType: .day) else { return .notValid }
        guard let validityEnd = validityEnd(hcert, dateFrom: validityFrom, dateUntil: validityUntil, additionalDays: recoveryEndDays) else { return .notValid }
                
        guard let currentDate = Date.startOfDay else { return .notValid }
        
        return self.validate(currentDate, from: validityStart, to: validityEnd)
    }
    
    public func validityEnd(_ hcert: HCert, dateFrom: Date, dateUntil: Date, additionalDays: Int) -> Date? {
        guard let validityExtension = dateFrom.add(additionalDays, ofType: .day) else { return nil }
        return dateUntil > validityExtension ? dateUntil : validityExtension
    }
 
    func getEndDays(from hcert: HCert) -> Int? {
        let endDaysConfig: String
        if isSpecialRecovery(hcert: hcert) {
            endDaysConfig = Constants.recoverySpecialEndDays
        }
        else {
            endDaysConfig = Constants.recoveryEndDays_IT
        }
        return getValue(for: endDaysConfig)?.intValue
    }
    
    func getStartDays(from hcert: HCert) -> Int? {
        let startDaysConfig: String
        if isSpecialRecovery(hcert: hcert) {
            startDaysConfig = Constants.recoverySpecialStartDays
        }
        else {
            startDaysConfig = Constants.recoveryStartDays_IT
        }
        return getValue(for: startDaysConfig)?.intValue
    }
   
    public func isSpecialRecovery(hcert: HCert) -> Bool {
        guard hcert.rcountryCode?.uppercased() == Constants.ItalyCountryCode.uppercased() else { return false }
        guard let signedCerficate = hcert.signedCerficate else { return false }
        let extendedKeyUsage = signedCerficate.extendedKeyUsage
        let validKeysUsages = extendedKeyUsage.filter{ $0 == Constants.OID_RECOVERY || $0 == Constants.OID_RECOVERY_ALT }
        return !validKeysUsages.isEmpty
    }
    
    public func getValue(for name: String) -> String? {
        return LocalData.getSetting(from: name)
    }
    
}

class RecoveryReinforcedValidator: RecoveryBaseValidator {
    
    override func getStartDays(from hcert: HCert) -> Int? {
        let startDaysConfig: String
        if isSpecialRecovery(hcert: hcert) {
            startDaysConfig = Constants.recoverySpecialStartDays
        }
        else {
            startDaysConfig = Constants.recoveryStartDays_IT
        }
        return getValue(for: startDaysConfig)?.intValue
    }
    
    override func getEndDays(from hcert: HCert) -> Int? {
        let endDaysConfig: String
        if isSpecialRecovery(hcert: hcert) {
            endDaysConfig = Constants.recoverySpecialEndDays
        }
        else {
            endDaysConfig = Constants.recoveryEndDays_IT
        }
        return getValue(for: endDaysConfig)?.intValue
    }
    
}

class RecoveryBoosterValidator: RecoveryReinforcedValidator {
    
    override func validate(hcert: HCert) -> Status {
        self.recoveryInfo = RecoveryInfo.from(hcert: hcert)
        
        guard let validityFrom = hcert.recoveryDateFrom?.toRecoveryDate else { return .notValid }
        guard let validityUntil = hcert.recoveryDateUntil?.toRecoveryDate else { return .notValid }

        guard let recoveryStartDays = getStartDays(from: hcert) else { return .notValid }
        guard let recoveryEndDays = getEndDays(from: hcert) else { return .notValid }
        
        guard let validityStart = validityFrom.add(recoveryStartDays, ofType: .day) else { return .notValid }
        guard let validityEnd = validityEnd(hcert, dateFrom: validityFrom, dateUntil: validityUntil, additionalDays: recoveryEndDays) else { return .notValid }
        
        guard let currentDate = Date.startOfDay else { return .notValid }
        
        return validate(currentDate, from: validityStart, to: validityEnd)
    }
    
    func validate(_ current: Date, from validityStart: Date, to validityEnd: Date) -> Status {
        switch current {
            case ..<validityStart:
                return .notValidYet
            case validityStart...validityEnd:
                return self.recoveryInfo.isCBIS ? .valid : .verificationIsNeeded
            default:
                return .expired
        }
    }
    
}

class RecoverySchoolValidator: RecoveryBaseValidator {
    
    override func validate(hcert: HCert) -> Status {
        
        guard let validityFrom = hcert.recoveryDateFirstPositive?.toRecoveryDate else { return .notValid }
        
        guard let recoveryStartDays = getStartDays(from: hcert) else { return .notValid }
        guard let recoveryEndDays = getEndDays(from: hcert) else { return .notValid }
        
        guard let validityStart = validityFrom.add(recoveryStartDays, ofType: .day) else { return .notValid }
        guard let validityEnd = validityFrom.add(recoveryEndDays, ofType: .day) else { return .notValid }
        
        guard let currentDate = Date.startOfDay else { return .notValid }
        
        return self.validate(currentDate, from: validityStart, to: validityEnd)
    }
    
    override func getEndDays(from hcert: HCert) -> Int? {
        var endDaysConfig = Constants.recoverySchoolEndDays
        if isSpecialRecovery(hcert: hcert) {
            endDaysConfig = Constants.recoverySpecialEndDays
        }
        return getValue(for: endDaysConfig)?.intValue
    }
    
    override func validityEnd(_ hcert: HCert, dateFrom: Date, dateUntil: Date, additionalDays: Int) -> Date? {
        if isSpecialRecovery(hcert: hcert) {
            guard let validityExtension = dateFrom.add(additionalDays, ofType: .day) else { return nil }
            return validityExtension
        }
        else {
            guard let recoveryDateFirstPositive = hcert.recoveryDateFirstPositive?.toRecoveryDate else { return nil }
            guard let validityExtension = recoveryDateFirstPositive.add(additionalDays, ofType: .day) else { return nil }
            return validityExtension
        }
    }
    
}

class RecoveryWorkValidator: RecoveryBaseValidator {
    
    override func getStartDays(from hcert: HCert) -> Int? {
        return super.getStartDays(from: hcert)
    }
    
    override func getEndDays(from hcert: HCert) -> Int? {
        return super.getEndDays(from: hcert)
    }
    
}

class RecoveryItalyEntryValidator: RecoveryBaseValidator {
    override func getStartDays(from hcert: HCert) -> Int? {
        let startDaysConfig: String
        if isSpecialRecovery(hcert: hcert) {
            startDaysConfig = Constants.recoverySpecialStartDays
        }
        else {
            startDaysConfig = Constants.recoveryStartDays_NOT_IT
        }
        return getValue(for: startDaysConfig)?.intValue
    }
    
    override func getEndDays(from hcert: HCert) -> Int? {
        let endDaysConfig: String
        if isSpecialRecovery(hcert: hcert) {
            endDaysConfig = Constants.recoverySpecialEndDays
        }
        else {
            endDaysConfig = Constants.recoveryEndDays_NOT_IT
        }
        return getValue(for: endDaysConfig)?.intValue
    }
}

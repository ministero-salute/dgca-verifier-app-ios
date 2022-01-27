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
        
        guard let recoveryValidFromDate = validFrom.toRecoveryDate else { return .notValid }
        guard let recoveryValidUntilDate = validUntil.toRecoveryDate else { return .notValid }
        
        var start: Int?
        var end: Int?
        
        let scanMode: String = Store.get(key: .scanMode) ?? ""
        switch scanMode {
        case Constants.scanMode2G:
            start = getStartDays(from: hcert)
            end = getEndDays(from: hcert)
        case Constants.scanMode3G:
            start = getStartDays3G(from: hcert)
            end = getEndDays3G(from: hcert)
        case Constants.scanModeBooster:
            start = getStartDays(from: hcert)
            end = getEndDays(from: hcert)
        default:
            return .notValid
        }
        
        guard let recoveryStartDays = start else { return .notGreenPass }
        guard let recoveryEndDays = end else { return .notGreenPass }
        
        guard let validityStart = recoveryValidFromDate.add(recoveryStartDays, ofType: .day) else { return .notValid }
        let validityEnd = recoveryValidUntilDate
        guard let validityExtension = recoveryValidFromDate.add(recoveryEndDays, ofType: .day) else { return .notValid }

        guard let currentDate = Date.startOfDay else { return .notValid }
        
        let recoveryStatus = Validator.validate(currentDate, from: validityStart, to: validityEnd, extendedTo: validityExtension)
        
        guard scanMode != Constants.scanModeBooster else { return recoveryStatus == .valid ? .verificationIsNeeded : recoveryStatus }
        
        return recoveryStatus
    }
    
    private func getStartDays3G(from hcert: HCert) -> Int? {
        let isITCode = hcert.countryCode == Constants.ItalyCountryCode
        let startDaysConfig: String
        if isSpecialRecovery(hcert: hcert){
            startDaysConfig = Constants.recoverySpecialStartDays
        }
        else {
            startDaysConfig = isITCode ? Constants.recoveryStartDays_IT : Constants.recoveryStartDays_NOT_IT
        }
        return getValue(for: startDaysConfig)?.intValue
    }
    
    private func getEndDays3G(from hcert: HCert) -> Int? {
        let isITCode = hcert.countryCode == Constants.ItalyCountryCode
        let startDaysConfig: String
        if isSpecialRecovery(hcert: hcert){
            startDaysConfig = Constants.recoverySpecialEndDays
        }
        else {
            startDaysConfig = isITCode ? Constants.recoveryEndDays_IT : Constants.recoveryEndDays_NOT_IT
        }
        return getValue(for: startDaysConfig)?.intValue
    }
    
    private func getStartDays(from hcert: HCert) -> Int? {
        let startDaysConfig = isSpecialRecovery(hcert: hcert) ? Constants.recoverySpecialStartDays : Constants.recoveryStartDays_IT
        return getValue(for: startDaysConfig)?.intValue
    }
    
    private func getEndDays(from hcert: HCert) -> Int? {
        let endDaysConfig = isSpecialRecovery(hcert: hcert) ? Constants.recoverySpecialEndDays : Constants.recoveryEndDays_IT
        return getValue(for: endDaysConfig)?.intValue
    }
    
    private func isSpecialRecovery(hcert: HCert) -> Bool {
        guard hcert.rcountryCode?.uppercased() == Constants.ItalyCountryCode.uppercased() else { return false }
        guard let signedCerficate = hcert.signedCerficate else { return false }
        let extendedKeyUsage = signedCerficate.extendedKeyUsage
        let validKeysUsages = extendedKeyUsage.filter{ $0 == Constants.OID_RECOVERY || $0 == Constants.OID_RECOVERY_ALT}
        return !validKeysUsages.isEmpty
    }
    
    private func getValue(for name: String) -> String? {
        return LocalData.getSetting(from: name)
    }
}

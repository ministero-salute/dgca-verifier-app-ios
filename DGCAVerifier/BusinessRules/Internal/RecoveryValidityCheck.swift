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

    private func validityEnd(_ hcert: HCert, dateFrom: Date, dateUntil: Date, additionalDays: Int) -> Date? {
        if isSchoolScanMode() {
            guard let recoveryDateFirstPositive = hcert.recoveryDateFirstPositive?.toRecoveryDate else { return nil }
            guard let validityExtension = recoveryDateFirstPositive.add(additionalDays, ofType: .day) else { return nil }
            return dateUntil < validityExtension ? dateUntil : validityExtension
            
        } else {
            guard let validityExtension = dateFrom.add(additionalDays, ofType: .day) else { return nil }
            return dateUntil > validityExtension ? dateUntil : validityExtension
        }
    }
    
    func isRecoveryValid(_ hcert: HCert) -> Status {
       
        guard let validityFrom = hcert.recoveryDateFrom?.toRecoveryDate else { return .notValid }
        guard let validityUntil = hcert.recoveryDateUntil?.toRecoveryDate else { return .notValid }

        guard let recoveryStartDays = getStartDays(from: hcert) else { return .notValid }
        guard let recoveryEndDays = getEndDays(from: hcert) else { return .notValid }
        
        guard let validityStart = validityFrom.add(recoveryStartDays, ofType: .day) else { return .notValid }
        guard let validityEnd = validityEnd(hcert, dateFrom: validityFrom, dateUntil: validityUntil, additionalDays: recoveryEndDays) else { return .notValid }
        
        guard let currentDate = Date.startOfDay else { return .notValid }
        
        let recoveryStatus = Validator.validate(currentDate, from: validityStart, to: validityEnd)
        
        guard !isBoosterScanMode() else { return recoveryStatus == .valid ? .verificationIsNeeded : recoveryStatus }
        
        return recoveryStatus
    }

    private func getEndDays(from hcert: HCert) -> Int? {
        let scanMode: String = Store.get(key: .scanMode) ?? ""
        let isSpecialRecovery = isSpecialRecovery(hcert: hcert)
        switch scanMode {
        case Constants.scanMode2G, Constants.scanModeBooster:
            let endDaysConfig = isSpecialRecovery ? Constants.recoverySpecialEndDays : Constants.recoveryEndDays_IT
            return getValue(for: endDaysConfig)?.intValue
        case Constants.scanMode3G:
            let isITCode = hcert.countryCode == Constants.ItalyCountryCode
            let endDaysConfig: String
            if isSpecialRecovery{
                endDaysConfig = Constants.recoverySpecialEndDays
            }
            else {
                endDaysConfig = isITCode ? Constants.recoveryEndDays_IT : Constants.recoveryEndDays_NOT_IT
            }
            return getValue(for: endDaysConfig)?.intValue
        case Constants.scanModeSchool:
            let endDaysConfig = Constants.recoverySchoolEndDays
            return getValue(for: endDaysConfig)?.intValue
        default:
            return nil
        }
    }
    
    private func getStartDays(from hcert: HCert) -> Int? {
        let scanMode: String = Store.get(key: .scanMode) ?? ""
        let isSpecialRecovery = isSpecialRecovery(hcert: hcert)
        switch scanMode {
        case Constants.scanMode2G, Constants.scanModeBooster:
            let startDaysConfig = isSpecialRecovery ? Constants.recoverySpecialStartDays : Constants.recoveryStartDays_IT
            return getValue(for: startDaysConfig)?.intValue
        case Constants.scanMode3G:
            let isITCode = hcert.countryCode == Constants.ItalyCountryCode
            let startDaysConfig: String
            if isSpecialRecovery{
                startDaysConfig = Constants.recoverySpecialStartDays
            }
            else {
                startDaysConfig = isITCode ? Constants.recoveryStartDays_IT : Constants.recoveryStartDays_NOT_IT
            }
            return getValue(for: startDaysConfig)?.intValue
        case Constants.scanModeSchool:
            let startDaysConfig = Constants.recoveryStartDays_IT
            return getValue(for: startDaysConfig)?.intValue
        default:
            return nil
        }
    }
    
    private func isSchoolScanMode() -> Bool{
        let scanMode: String = Store.get(key: .scanMode) ?? ""
        return scanMode == Constants.scanModeSchool
    }
    
    private func isBoosterScanMode() -> Bool{
        let scanMode: String = Store.get(key: .scanMode) ?? ""
        return scanMode == Constants.scanModeBooster
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

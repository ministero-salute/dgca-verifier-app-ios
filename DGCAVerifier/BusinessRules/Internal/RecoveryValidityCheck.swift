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
    
//    private func getValidityFrom (from hcert: HCert) -> String? {
//        return isSchoolScanMode() ? hcert.recoveryDateFirstPositive : hcert.recoveryDateFrom
//    }
    
    private func getValidityUntil (from hcert: HCert) -> Date? {
        guard let recoveryDateFirstPositive = hcert.recoveryDateFirstPositive?.toRecoveryDate else {return nil}
        guard let recoveryDateUntil = hcert.recoveryDateUntil?.toRecoveryDate else {return nil}
        guard let vaccineSchoolEndDays = getValue(for: Constants.vaccineSchoolEndDays)?.intValue else {return nil}
        guard let recoveryDate = recoveryDateFirstPositive.add(vaccineSchoolEndDays, ofType: .day) else {return nil}
        if isSchoolScanMode() {
            if (recoveryDate < recoveryDateUntil) {
                return recoveryDate
            }
            else {
                return recoveryDateUntil
            }
        }
        else {
            return recoveryDateUntil
        }
    }
        
    func isRecoveryValid(_ hcert: HCert) -> Status {
        guard let validFrom = hcert.recoveryDateFrom else { return .notValid }
//        guard let validUntil = hcert.recoveryDateUntil else { return .notValid }
        
        guard let recoveryValidFromDate = validFrom.toRecoveryDate else { return .notValid }
        guard let recoveryValidUntilDate = getValidityUntil(from: hcert) else { return .notValid }

        guard let recoveryStartDays = getStartDays(from: hcert) else { return .notGreenPass }
        guard let recoveryEndDays = getEndDays(from: hcert) else { return .notGreenPass }
        
        guard let validityStart = recoveryValidFromDate.add(recoveryStartDays, ofType: .day) else { return .notValid }
        let validityEnd = recoveryValidUntilDate
        guard let validityExtension = recoveryValidFromDate.add(recoveryEndDays, ofType: .day) else { return .notValid }

        guard let currentDate = Date.startOfDay else { return .notValid }
        
        let recoveryStatus: Status
        if isSchoolScanMode() {
            recoveryStatus = Validator.validate(currentDate, from: validityStart, to: validityEnd)
        }
        else {
            recoveryStatus = Validator.validate(currentDate, from: validityStart, to: validityEnd, extendedTo: validityExtension)
        }
        
        guard isBoosterScanMode() else { return recoveryStatus == .valid ? .verificationIsNeeded : recoveryStatus }
        
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
            let startDaysConfig = Constants.recoverySchoolStartDays
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

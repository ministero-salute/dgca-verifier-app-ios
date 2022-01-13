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
//  VaccineValidityCheck.swift
//  Verifier
//
//  Created by Davide Aliti on 21/05/21.
//

import Foundation
import SwiftDGC

struct VaccineValidityCheck {
    
    typealias Validator = MedicalRulesValidator
    
    private var allowedVaccinationInCountry: [String: [String]] {
        [Constants.SputnikVacineCode: [Constants.sanMarinoCode]]
    }
    
    struct CertificatePreconditions {
        let currentDoses: Int
        let totalDoses: Int
        let medicalProduct: String
        let vaccineDate: Date
        var lastDose: Bool {
            self.currentDoses >= self.totalDoses
        }
    }
    
    func checkPreconditions(_ hcert: HCert) -> CertificatePreconditions? {
        guard let currentDoses = hcert.currentDosesNumber, currentDoses > 0 else { return nil }
        guard let totalDoses = hcert.totalDosesNumber, totalDoses > 0 else { return nil }
        guard let vaccineDate = hcert.vaccineDate?.toVaccineDate else { return nil }
        guard let medicalProduct = hcert.medicalProduct else { return nil }
        guard isValid(for: medicalProduct) else { return nil }
        guard let countryCode = hcert.countryCode else { return nil }
        guard isAllowedVaccination(for: medicalProduct, fromCountryWithCode: countryCode) else { return nil }
        
        if isScanModeSchool() && currentDoses < totalDoses {
            return nil
        }
        
        return CertificatePreconditions(currentDoses: currentDoses, totalDoses: totalDoses, medicalProduct: medicalProduct, vaccineDate: vaccineDate)
    }
    
    func checkCertificateDate(_ preconditions: CertificatePreconditions) -> Status {
        guard let start = getStartDays(for: preconditions.medicalProduct, preconditions.lastDose) else { return .notGreenPass }
        guard let end = getEndDays(for: preconditions.medicalProduct, preconditions.lastDose) else { return .notGreenPass }

        guard let validityStart = preconditions.vaccineDate.add(start, ofType: .day) else { return .notValid }
        guard let validityEnd = preconditions.vaccineDate.add(end, ofType: .day)?.startOfDay else { return .notValid }

        guard let currentDate = Date.startOfDay else { return .notValid }
        let isJJBooster = isJJBooster(preconditions)
        let fromDate = isJJBooster ? preconditions.vaccineDate : validityStart

        return Validator.validate(currentDate, from: fromDate, to: validityEnd)
    }
    
    func isJJBooster(_ preconditions: CertificatePreconditions) -> Bool {
        let isJJ = preconditions.medicalProduct == Constants.JeJVacineCode
        return isJJ && isaJJBoosterDose(current: preconditions.currentDoses, total: preconditions.totalDoses)
    }
    
    func isScanModeBooster () -> Bool {
        let scanMode: String = Store.get(key: .scanMode) ?? ""
        return scanMode == Constants.scanModeBooster
    }
    
    func isScanModeSchool () -> Bool {
        let scanMode: String = Store.get(key: .scanMode) ?? ""
        return scanMode == Constants.scanModeSchool
    }
    
    func isaBooster (_ preconditions: CertificatePreconditions) -> Bool {
        let isJJBooster = isJJBooster(preconditions)
        
        let isaBoosterDose = preconditions.currentDoses > preconditions.totalDoses ||
        preconditions.currentDoses >= Constants.boosterMinimumDosesNumber || isJJBooster
        
        return isaBoosterDose
    }
    
    func checkBooster (_ preconditions: CertificatePreconditions) -> Status{
        let isJJBooster = isJJBooster(preconditions)
        
        let isaBoosterDose = preconditions.currentDoses > preconditions.totalDoses ||
        preconditions.currentDoses >= Constants.boosterMinimumDosesNumber || isJJBooster
        
        if isaBoosterDose { return . valid }
        return preconditions.lastDose ? .verificationIsNeeded : .notValid
    }
    
    func isVaccineValid(_ hcert: HCert) -> Status {
        guard let preconditions = checkPreconditions(hcert) else { return .notValid }
        let result = checkCertificateDate(preconditions)
        
        guard result == .valid else { return result }

        guard !isScanModeBooster() else {
            return checkBooster(preconditions)
        }

        return result
    }
    
    private func isaJJBoosterDose(current: Int, total: Int) -> Bool {
        return current > total || (current == total && current >= Constants.jjBoosterMinimumDosesNumber)
    }
    
    private func isAllowedVaccination(for medicalProduct: String, fromCountryWithCode countryCode: String) -> Bool {
        if let allowedCountries = allowedVaccinationInCountry[medicalProduct] {
            return allowedCountries.contains(countryCode)
        }
        return true
    }
    
    private func isValid(for medicalProduct: String) -> Bool {
        // Vaccine code not included in settings -> not a valid vaccine for Italy
        let name = Constants.vaccineCompleteEndDays
        return getValue(for: name, type: medicalProduct) != nil
    }
     
    private func getStartDays(for medicalProduct: String, _ isLastDose: Bool) -> Int? {
        let scanMode: String = Store.get(key: .scanMode) ?? ""
        var startDaysConfig: String
        if scanMode == Constants.scanModeSchool {
            startDaysConfig = Constants.vaccineSchoolStartDays
            return getValue(for: startDaysConfig)?.intValue
        }
        else {
            startDaysConfig = isLastDose ? Constants.vaccineCompleteStartDays : Constants.vaccineIncompleteStartDays
            return getValue(for: startDaysConfig, type: medicalProduct)?.intValue
        }
    }
    
    private func getEndDays(for medicalProduct: String, _ isLastDose: Bool) -> Int? {
        let scanMode: String = Store.get(key: .scanMode) ?? ""
        var endDaysConfig: String
        if scanMode == Constants.scanModeSchool {
            endDaysConfig = Constants.vaccineSchoolEndDays
            return getValue(for: endDaysConfig)?.intValue
        }
        else {
            endDaysConfig = isLastDose ? Constants.vaccineCompleteEndDays : Constants.vaccineIncompleteEndDays
            return getValue(for: endDaysConfig, type: medicalProduct)?.intValue
        }
    }
    
    private func getValue(for name: String, type: String) -> String? {
        return LocalData.getSetting(from: name, type: type)
    }
    
    private func getValue(for name: String) -> String? {
        return LocalData.getSetting(from: name)
    }
    
}

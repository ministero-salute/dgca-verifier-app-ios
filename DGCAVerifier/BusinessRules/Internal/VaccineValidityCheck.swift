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
    
    func isVaccineDateValid(_ hcert: HCert) -> Status {
        guard let currentDoses = hcert.currentDosesNumber else { return .notValid }
        guard let totalDoses = hcert.totalDosesNumber else { return .notValid }
        guard currentDoses > 0 else { return .notValid }
        guard totalDoses > 0 else { return .notValid }
        let lastDose = currentDoses >= totalDoses
        
        guard let product = hcert.medicalProduct else { return .notValid }
        guard isValid(for: hcert) else { return .notValid }
        guard let countryCode = hcert.countryCode else { return .notValid }
        guard isAllowedVaccination(for: product, fromCountryWithCode: countryCode) else { return .notValid }
        
        var start: Int?
        var end: Int?
        
        let scanMode: String = Store.get(key: .scanMode) ?? ""
        switch scanMode {
        case Constants.scanMode2G:
            start = getStartDays2G(for: hcert, lastDose)
            end = getEndDays2G(for: hcert, lastDose)
        case Constants.scanMode3G:
            start = getStartDays3G(for: hcert, lastDose)
            end = getEndDays3G(for: hcert, lastDose)
        case Constants.scanModeBooster:
            start = getStartDaysBooster(for: hcert, lastDose)
            end = getEndDaysBooster(for: hcert, lastDose)
        default:
            return .notValid
        }
        
        guard let startDate = start, let endDate = end else { return .notValid }
        guard let dateString = hcert.vaccineDate else { return .notValid }
        guard let date = dateString.toVaccineDate else { return .notValid }
        guard let validityStart = date.add(startDate, ofType: .day) else { return .notValid }
        guard let validityEnd = date.add(endDate, ofType: .day)?.startOfDay else { return .notValid }

        guard let currentDate = Date.startOfDay else { return .notValid }

        let isJJ = hcert.medicalProduct == Constants.JeJVacineCode
        let isJJBooster = isJJ && isaJJBoosterDose(current: currentDoses, total: totalDoses)
        let fromDate = isJJBooster ? date : validityStart

        let result = Validator.validate(currentDate, from: fromDate, to: validityEnd)
        
        guard result == .valid else { return result }

        if scanMode == Constants.scanModeBooster {
            if isBoosterDoses(hcert: hcert) { return . valid }
            return lastDose ? .verificationIsNeeded : .notValid
        }

        return result
    }
    
    private func isBoosterDoses (hcert: HCert) -> Bool {
        guard let currentDoses = hcert.currentDosesNumber, let totalDoses = hcert.totalDosesNumber else { return false }
        let isJJ = hcert.medicalProduct == Constants.JeJVacineCode
        let isJJBooster = isJJ && isaJJBoosterDose(current: currentDoses, total: totalDoses)
        let isaBoosterDose = currentDoses > totalDoses ||
            currentDoses >= Constants.boosterMinimumDosesNumber || isJJBooster
        return isaBoosterDose
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
    
    private func isValid(for hcert: HCert) -> Bool {
        // Vaccine code not included in settings -> not a valid vaccine for Italy
        guard let countryCode = hcert.countryCode, let medicalProduct = hcert.medicalProduct else { return false }
        var name: String
        if countryCode == Constants.ItalyCountryCode {
            name = Constants.vaccineCompleteEndDays_IT
        }
        else {
            name = Constants.vaccineCompleteEndDays_NOT_IT
        }
        return getValue(for: name, type: medicalProduct) != nil
    }
     
    private func getStartDays3G(for hcert: HCert, _ isLastDose: Bool) -> Int? {
        guard let countryCode = hcert.countryCode, let medicalProduct = hcert.medicalProduct else { return nil }
        var name: String
        if !isLastDose {
            name = Constants.vaccineIncompleteStartDays
        }
        else {
            let isITCode =  countryCode == Constants.ItalyCountryCode
            name = isITCode ? Constants.vaccineCompleteStartDays_IT : Constants.vaccineCompleteStartDays_NOT_IT
        }
        return getValue(for: name, type: medicalProduct)?.intValue
    }
    
    private func getEndDays3G(for hcert: HCert, _ isLastDose: Bool) -> Int? {
        guard let countryCode = hcert.countryCode, let medicalProduct = hcert.medicalProduct else { return nil }
        var name: String
        if !isLastDose {
            name = Constants.vaccineIncompleteEndDays
        }
        else {
            let isITCode =  countryCode == Constants.ItalyCountryCode
            name = isITCode ? Constants.vaccineCompleteEndDays_IT : Constants.vaccineCompleteEndDays_NOT_IT
        }
        return getValue(for: name, type: medicalProduct)?.intValue
    }
    
    private func getStartDays2G(for hcert: HCert, _ isLastDose: Bool) -> Int? {
        guard let medicalProduct = hcert.medicalProduct else { return nil }
        let name = isLastDose ? Constants.vaccineCompleteStartDays_IT : Constants.vaccineIncompleteStartDays
        return getValue(for: name, type: medicalProduct)?.intValue
    }
    
    private func getEndDays2G(for hcert: HCert, _ isLastDose: Bool) -> Int? {
        guard let medicalProduct = hcert.medicalProduct else { return nil }
        let name = isLastDose ? Constants.vaccineCompleteEndDays_IT : Constants.vaccineIncompleteEndDays
        return getValue(for: name, type: medicalProduct)?.intValue
    }
    
    private func getStartDaysBooster(for hcert: HCert, _ isLastDose: Bool) -> Int? {
        guard let medicalProduct = hcert.medicalProduct, isLastDose else { return nil }
        let name: String
        if isBoosterDoses(hcert: hcert){
            name = Constants.vaccineBoosterStartDays_IT
        }
        else {
            name = Constants.vaccineCompleteStartDays_IT
        }
        return getValue(for: name, type: medicalProduct)?.intValue
    }
    
    private func getEndDaysBooster(for hcert: HCert, _ isLastDose: Bool) -> Int? {
        guard let medicalProduct = hcert.medicalProduct, isLastDose else { return nil }
        let name: String
        if isBoosterDoses(hcert: hcert){
            name = Constants.vaccineBoosterEndDays_IT
        }
        else {
            name = Constants.vaccineCompleteEndDays_IT
        }
        return getValue(for: name, type: medicalProduct)?.intValue
    }
    
    private func getValue(for name: String, type: String) -> String? {
        return LocalData.getSetting(from: name, type: type)
    }
    
}

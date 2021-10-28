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
    
    private let incompleteStartDays = "vaccine_start_day_not_complete"
    private let incompleteEndDays = "vaccine_end_day_not_complete"

    private let completeStartDays = "vaccine_start_day_complete"
    private let completeEndDays = "vaccine_end_day_complete"
    
    private let JeJVacineCode = "EU/1/20/1525"
    private let SputnikVacineCode = "Sputnik-V"
    private let sanMarinoCode = "SM"
    
    private var allowedVaccinationInCountry: [String: [String]] {
        [SputnikVacineCode: [sanMarinoCode]]
    }
    
    func isVaccineDateValid(_ hcert: HCert) -> Status {
        guard let currentDoses = hcert.currentDosesNumber else { return .notValid }
        guard let totalDoses = hcert.totalDosesNumber else { return .notValid }
        guard currentDoses > 0 else { return .notValid }
        guard totalDoses > 0 else { return .notValid }
        let lastDose = currentDoses >= totalDoses
        
        guard let product = hcert.medicalProduct else { return .notValid }
        guard isValid(for: product) else { return .notValid }
        guard let countryCode = hcert.countryCode else { return .notValid }
        guard isAllowedVaccination(for: product, fromCountryWithCode: countryCode) else { return .notValid }
        
        guard let start = getStartDays(for: product, lastDose) else { return .notGreenPass }
        guard let end = getEndDays(for: product, lastDose) else { return .notGreenPass }
        
        guard let dateString = hcert.vaccineDate else { return .notValid }
        guard let date = dateString.toVaccineDate else { return .notValid }
        guard let validityStart = date.add(start, ofType: .day) else { return .notValid }
        guard let validityEnd = date.add(end, ofType: .day)?.toDateString.toDate else { return .notValid }

        guard let currentDate = Date.startOfDay else { return .notValid }
        
        let result: Status
        
        if hcert.medicalProduct == JeJVacineCode && currentDoses > totalDoses{
            result = Validator.validate(currentDate, from: date, to: validityEnd)
        }
        else{
            result = Validator.validate(currentDate, from: validityStart, to: validityEnd)
        }
        
        guard result == .valid else { return result }
        if !lastDose { return .validPartially }
        return result
        
    }
    
    private func isAllowedVaccination(for medicalProduct: String, fromCountryWithCode countryCode: String) -> Bool {
        if let allowedCountries = allowedVaccinationInCountry[medicalProduct] {
            return allowedCountries.contains(countryCode)
        }
        return true
    }
    
    private func isValid(for medicalProduct: String) -> Bool {
        // Vaccine code not included in settings -> not a valid vaccine for Italy
        let name = completeEndDays
        return getValue(for: name, type: medicalProduct) != nil
    }
     
    private func getStartDays(for medicalProduct: String, _ isLastDose: Bool) -> Int? {
        let name = isLastDose ? completeStartDays : incompleteStartDays
        return getValue(for: name, type: medicalProduct)?.intValue
    }
    
    private func getEndDays(for medicalProduct: String, _ isLastDose: Bool) -> Int? {
        let name = isLastDose ? completeEndDays : incompleteEndDays
        return getValue(for: name, type: medicalProduct)?.intValue
    }
    
    private func getValue(for name: String, type: String) -> String? {
        return LocalData.getSetting(from: name, type: type)
    }
    
}

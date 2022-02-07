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
//  VaccineValidators.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 01/02/22.
//

import Foundation
import SwiftDGC

struct VaccinationInfo {
    let currentDoses: Int
    let totalDoses: Int
    let medicalProduct: String
    let vaccineDate: Date
    let countryCode: String
    let patientAge: Int?
    
    var patientOver50: Bool {
        guard let age = patientAge else { return false }
        return age >= 50
    }
    
    var isIT: Bool { self.countryCode.uppercased() == Constants.ItalyCountryCode }
    var isJJ: Bool { self.medicalProduct == Constants.JeJVacineCode }
    
    var isJJBooster: Bool { self.isJJ && (self.currentDoses >= Constants.jjBoosterMinimumDosesNumber) }
    var isNonJJBooster: Bool { !self.isJJ && (self.currentDoses >= Constants.boosterMinimumDosesNumber) }
    
    var isCurrentDoseIncomplete: Bool { self.currentDoses < self.totalDoses }
    var isCurrentDoseComplete: Bool { self.currentDoses == self.totalDoses && !self.isJJBooster && !self.isNonJJBooster }
    var isCurrentDoseBooster: Bool { (self.currentDoses > self.totalDoses) || (isJJBooster || self.isNonJJBooster) }
}


class VaccineBaseValidator: DGCValidator {
    
    typealias Validator = VaccineBaseValidator
    
    private var allowedVaccinationInCountry: [String: [String]] {
        [Constants.SputnikVacineCode: [Constants.sanMarinoCode]]
    }
    
    func validate(hcert: HCert) -> Status {
        guard let vaccinationInfo = getVaccinationData(hcert) else { return .notValid }
        return checkVaccinationInterval(vaccinationInfo)
    }
    
    func getVaccinationData(_ hcert: HCert) -> VaccinationInfo? {
        guard let currentDoses = hcert.currentDosesNumber, currentDoses > 0 else { return nil }
        guard let totalDoses = hcert.totalDosesNumber, totalDoses > 0 else { return nil }
        guard let vaccineDate = hcert.vaccineDate?.toVaccineDate else { return nil }
        guard let medicalProduct = hcert.medicalProduct else { return nil }
        guard isValid(for: medicalProduct) else { return nil }
        guard let countryCode = hcert.countryCode else { return nil }
        guard isAllowedVaccination(for: medicalProduct, fromCountryWithCode: countryCode) else { return nil }
        
        return VaccinationInfo(currentDoses: currentDoses, totalDoses: totalDoses, medicalProduct: medicalProduct, vaccineDate: vaccineDate, countryCode: countryCode, patientAge: hcert.age)
    }
    
    func checkVaccinationInterval(_ vaccinationInfo: VaccinationInfo) -> Status {
       
        guard let start = getStartDays(vaccinationInfo: vaccinationInfo) else { return .notValid }
        guard let end = getEndDays(vaccinationInfo: vaccinationInfo) else { return .notValid }
        
        guard let validityStart = vaccinationInfo.vaccineDate.add(start, ofType: .day) else { return .notValid }
        guard let validityEnd = vaccinationInfo.vaccineDate.add(end, ofType: .day)?.startOfDay else { return .notValid }
        
        guard let currentDate = Date.startOfDay else { return .notValid }
        
        // J&J booster is immediately valid
        let fromDate = vaccinationInfo.isJJBooster ? vaccinationInfo.vaccineDate : validityStart
        
        return Validator.validate(currentDate, from: fromDate, to: validityEnd)
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
        
    public func startDaysSettingNameForBoosterDose(vaccinationInfo: VaccinationInfo) -> String {
        return vaccinationInfo.isIT ? Constants.vaccineBoosterStartDays_IT : Constants.vaccineBoosterStartDays_NOT_IT
    }
    
    public func startDaysSettingNameForIncompleteDose(vaccinationInfo: VaccinationInfo) -> String {
        return Constants.vaccineIncompleteStartDays
    }
    
    public func startDaysSettingNameForJJ(vaccinationInfo: VaccinationInfo) -> String {
        return Constants.vaccineCompleteStartDays
    }
    
    public func startDaysSettingNameForCompleteDose(vaccinationInfo: VaccinationInfo) -> String {
        return vaccinationInfo.isIT ? Constants.vaccineCompleteStartDays_IT : Constants.vaccineCompleteStartDays_NOT_IT
    }
    
    public func getStartDays(vaccinationInfo: VaccinationInfo) -> Int? {
        if vaccinationInfo.isCurrentDoseBooster {
            return self.getValue(for: startDaysSettingNameForBoosterDose(vaccinationInfo: vaccinationInfo))?.intValue
        }
        
        if vaccinationInfo.isCurrentDoseIncomplete {
            return self.getValue(for: startDaysSettingNameForIncompleteDose(vaccinationInfo: vaccinationInfo), type: vaccinationInfo.medicalProduct)?.intValue
        }
    
        if vaccinationInfo.isJJ {
            return self.getValue(for: startDaysSettingNameForJJ(vaccinationInfo: vaccinationInfo), type: vaccinationInfo.medicalProduct)?.intValue
        }
        
        return self.getValue(for: startDaysSettingNameForCompleteDose(vaccinationInfo: vaccinationInfo))?.intValue
    }
    

    public func endDaysSettingNameForBoosterDose(_ vaccinationInfo: VaccinationInfo) -> String {
        return vaccinationInfo.isIT ? Constants.vaccineBoosterEndDays_IT : Constants.vaccineBoosterEndDays_NOT_IT
    }
    
    public func endDaysSettingNameForIncompleteDose(_ vaccinationInfo: VaccinationInfo) -> String {
        return Constants.vaccineIncompleteEndDays
    }
    
    public func endDaysSettingNameForCompleteDose(_ vaccinationInfo: VaccinationInfo) -> String {
        return vaccinationInfo.isIT ? Constants.vaccineCompleteEndDays_IT : Constants.vaccineCompleteEndDays_NOT_IT
    }
    
    public func getEndDays(vaccinationInfo: VaccinationInfo) -> Int? {
        if vaccinationInfo.isCurrentDoseBooster {
            return self.getValue(for: endDaysSettingNameForBoosterDose(vaccinationInfo))?.intValue
        }
        
        if vaccinationInfo.isCurrentDoseIncomplete {
            return self.getValue(for: endDaysSettingNameForIncompleteDose(vaccinationInfo), type: vaccinationInfo.medicalProduct)?.intValue
        }
    
        return self.getValue(for: endDaysSettingNameForCompleteDose(vaccinationInfo))?.intValue
    }
    
    public func getValue(for name: String, type: String) -> String? {
        return LocalData.getSetting(from: name, type: type)
    }
    
    public func getValue(for name: String) -> String? {
        return LocalData.getSetting(from: name)
    }
    
}


class VaccineReinforcedValidator: VaccineBaseValidator {
    
    public override func startDaysSettingNameForBoosterDose(vaccinationInfo: VaccinationInfo) -> String {
        return Constants.vaccineBoosterStartDays_IT
    }
    
    public override func startDaysSettingNameForCompleteDose(vaccinationInfo: VaccinationInfo) -> String {
        return Constants.vaccineCompleteStartDays_IT
    }
    
    public override func endDaysSettingNameForBoosterDose(_ vaccinationInfo: VaccinationInfo) -> String {
        return Constants.vaccineBoosterEndDays_IT
    }
    
    public override func endDaysSettingNameForCompleteDose(_ vaccinationInfo: VaccinationInfo) -> String {
        return Constants.vaccineCompleteEndDays_IT
    }
    
}


class VaccineBoosterValidator: VaccineReinforcedValidator {
    
    override func validate(hcert: HCert) -> Status {
        guard let vaccinationInfo = getVaccinationData(hcert) else { return .notValid }
        let result = super.checkVaccinationInterval(vaccinationInfo)
        
        guard result == .valid else { return result }
        return checkBooster(vaccinationInfo)
    }
    
    private func checkBooster(_ vaccinationInfo: VaccinationInfo) -> Status {
        if vaccinationInfo.isCurrentDoseBooster { return . valid }
        return vaccinationInfo.isCurrentDoseComplete ? .verificationIsNeeded : .notValid
    }
    
}

class VaccineSchoolValidator: VaccineReinforcedValidator {
	
	override func validate(hcert: HCert) -> Status {
        guard let vaccinationInfo = getVaccinationData(hcert) else { return .notValid }
		let result = super.checkVaccinationInterval(vaccinationInfo)
		
		guard result == .valid else { return result }
		return vaccinationInfo.isCurrentDoseIncomplete ? .notValid : .valid
	}
    
    
    public override func endDaysSettingNameForCompleteDose(_ vaccinationInfo: VaccinationInfo) -> String {
        return Constants.vaccineSchoolEndDays
    }
    
}


class VaccineWorkValidator: VaccineBaseValidator {
    
    public override func startDaysSettingNameForBoosterDose(vaccinationInfo: VaccinationInfo) -> String {
        if (vaccinationInfo.isIT) {
            return Constants.vaccineBoosterStartDays_IT //180 days
        } else {
            return vaccinationInfo.patientOver50 ? Constants.vaccineBoosterStartDays_IT : Constants.vaccineBoosterStartDays_NOT_IT // 270 days
        }
    }
    
    public override func startDaysSettingNameForCompleteDose(vaccinationInfo: VaccinationInfo) -> String {
        if (vaccinationInfo.isIT) {
            return Constants.vaccineCompleteStartDays_IT
        } else {
            return vaccinationInfo.patientOver50 ? Constants.vaccineCompleteStartDays_IT : Constants.vaccineCompleteStartDays_NOT_IT
        }
    }
    
    public override func endDaysSettingNameForBoosterDose(_ vaccinationInfo: VaccinationInfo) -> String {
        if (vaccinationInfo.isIT) {
            return Constants.vaccineBoosterEndDays_IT
        } else {
            return vaccinationInfo.patientOver50 ? Constants.vaccineBoosterEndDays_IT : Constants.vaccineBoosterEndDays_NOT_IT
        }
    }
    
    public override func endDaysSettingNameForCompleteDose(_ vaccinationInfo: VaccinationInfo) -> String {
        if (vaccinationInfo.isIT) {
            return Constants.vaccineCompleteEndDays_IT
        } else {
            return vaccinationInfo.patientOver50 ? Constants.vaccineCompleteEndDays_IT : Constants.vaccineBoosterEndDays_NOT_IT
        }
    }
    
}

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
    let patientBirthDate: Date?
    
    var emaAllProducts: [String]?{
        return LocalData.getSetting(from: "EMA_vaccines")?.split(separator: ";").map{ String($0) }
    }
    
    var isIT: Bool { self.countryCode.uppercased() == Constants.ItalyCountryCode }
    var isJJ: Bool { self.medicalProduct == Constants.JeJVacineCode }
    
    var isJJBooster: Bool { self.isJJ && (self.currentDoses >= Constants.jjBoosterMinimumDosesNumber) }
    var isNonJJBooster: Bool { !self.isJJ && (self.currentDoses >= Constants.boosterMinimumDosesNumber) }
    
    var isCurrentDoseIncomplete: Bool { self.currentDoses < self.totalDoses }
    var isCurrentDoseComplete: Bool { self.currentDoses == self.totalDoses && !self.isJJBooster && !self.isNonJJBooster }
    var isCurrentDoseBooster: Bool { (self.currentDoses > self.totalDoses) || (isJJBooster || self.isNonJJBooster) }
    
    func isPatientUnder18(vaccineUnder18Offset: Int) -> Bool {
        guard let patientBirthDate = self.patientBirthDate?.add(vaccineUnder18Offset, ofType: .day) else { return false }
        let computedPatientAge = Calendar.current.dateComponents([.year, .month, .day], from: patientBirthDate, to: Date())
        guard let computedPatientAgeYear = computedPatientAge.year else { return false }
        return computedPatientAgeYear < 18
    }
    
    var isEMAProduct: Bool {
        if (emaAllProducts?.contains(medicalProduct) ?? false) // (Sputnik-V solo se emesso da San marino ovvero co="SM")
            || (countryCode == Constants.sanMarinoCode && medicalProduct == Constants.SputnikVacineCode) {
            return true
        }
        else {
            return false
        }
    }
    
}

class VaccineConcreteValidator: DGCValidator {
        
    var vaccinationInfo: VaccinationInfo!
    
    private var allowedVaccinationInCountry: [String: [String]] {
        [Constants.SputnikVacineCode: [Constants.sanMarinoCode]]
    }
    
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
    
    /// Override this method to manage the scan condition
    func validate(hcert: HCert) -> Status {
        guard let vaccinationInfo = getVaccinationData(hcert) else { return .notValid }
        self.vaccinationInfo = vaccinationInfo
        
        if !vaccinationInfo.isEMAProduct && vaccinationInfo.isCurrentDoseIncomplete {
            return .notValid
        }
        
        let result = checkVaccinationInterval(vaccinationInfo)
        
        guard result == .valid else { return result }
        guard vaccinationInfo.isEMAProduct else { return .notValid }
        
        return result
    }
    
    func getVaccinationData(_ hcert: HCert) -> VaccinationInfo? {
        guard let currentDoses = hcert.currentDosesNumber, currentDoses > 0 else { return nil }
        guard let totalDoses = hcert.totalDosesNumber, totalDoses > 0 else { return nil }
        guard let vaccineDate = hcert.vaccineDate?.toVaccineDate else { return nil }
        guard let medicalProduct = hcert.medicalProduct else { return nil }
        guard let countryCode = hcert.countryCode else { return nil }
        
        return VaccinationInfo(currentDoses: currentDoses, totalDoses: totalDoses, medicalProduct: medicalProduct, vaccineDate: vaccineDate, countryCode: countryCode, patientAge: hcert.age, patientBirthDate: hcert.birthDate)
    }
    
    func checkVaccinationInterval(_ vaccinationInfo: VaccinationInfo) -> Status {
        guard let start = getStartDays(vaccinationInfo: vaccinationInfo) else { return .notValid }
        guard let end = getEndDays(vaccinationInfo: vaccinationInfo) else { return .notValid }
        guard let ext = getExtensionDays(vaccinationInfo: vaccinationInfo) else { return .notValid }
        
        guard let validityStart = vaccinationInfo.vaccineDate.add(start, ofType: .day) else { return .notValid }
        guard let validityEnd = vaccinationInfo.vaccineDate.add(end, ofType: .day)?.startOfDay else { return .notValid }
        guard let validityExt = vaccinationInfo.vaccineDate.add(ext, ofType: .day)?.startOfDay else { return .notValid }
        
        guard let currentDate = Date.startOfDay else { return .notValid }
        
        // J&J booster is immediately valid
        let fromDate = vaccinationInfo.isJJBooster ? vaccinationInfo.vaccineDate : validityStart
        
        return self.validate(currentDate, from: fromDate, to: validityEnd, extendedTo: validityExt)
    }
    
    private func isAllowedVaccination(for medicalProduct: String, fromCountryWithCode countryCode: String) -> Bool {
        if let allowedCountries = allowedVaccinationInCountry[medicalProduct] {
            return allowedCountries.contains(countryCode)
        }
        return true
    }
    
    public func startDaysForBoosterDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        let setting = Constants.vaccineBoosterStartDays_IT
        return self.getValue(for: setting)?.intValue
    }
    
    public func startDaysForIncompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        let setting = Constants.vaccineIncompleteStartDays
        return self.getValue(for: setting, type: vaccinationInfo.medicalProduct)?.intValue
    }
    
    public func startDaysForJJ(_ vaccinationInfo: VaccinationInfo) -> Int? {
        let setting = Constants.vaccineCompleteStartDays
        return self.getValue(for: setting, type: vaccinationInfo.medicalProduct)?.intValue
    }
    
    public func startDaysForCompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        let setting = Constants.vaccineCompleteStartDays_IT
        return self.getValue(for: setting)?.intValue
    }
    
    public func getStartDays(vaccinationInfo: VaccinationInfo) -> Int? {
        if vaccinationInfo.isCurrentDoseBooster {
            return startDaysForBoosterDose(vaccinationInfo)
        }
        
        if vaccinationInfo.isCurrentDoseIncomplete {
            return startDaysForIncompleteDose(vaccinationInfo)
        }
    
        if vaccinationInfo.isJJ {
            return startDaysForJJ(vaccinationInfo)
        }
        
        return startDaysForCompleteDose(vaccinationInfo)
    }
    
    public func endDaysForBoosterDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        let setting = Constants.vaccineBoosterEndDays_IT
        return self.getValue(for: setting)?.intValue
    }
    
    public func endDaysForIncompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        return self.getValue(for: Constants.vaccineIncompleteEndDays, type: vaccinationInfo.medicalProduct)?.intValue
    }
    
    public func endDaysForCompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        let setting = Constants.vaccineCompleteEndDays_IT
        return self.getValue(for: setting)?.intValue
    }
    
    public func getEndDays(vaccinationInfo: VaccinationInfo) -> Int? {
        if vaccinationInfo.isCurrentDoseBooster {
            return endDaysForBoosterDose(vaccinationInfo)
        }
        
        if vaccinationInfo.isCurrentDoseIncomplete {
            return endDaysForIncompleteDose(vaccinationInfo)
        }
    
        return endDaysForCompleteDose(vaccinationInfo)
    }
    
    public func extDaysForBoosterDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        return endDaysForBoosterDose(vaccinationInfo)
    }
    
    public func extDaysForIncompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        return endDaysForIncompleteDose(vaccinationInfo)
    }
    
    public func extDaysForCompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        return endDaysForCompleteDose(vaccinationInfo)
    }
    

    public func getExtensionDays(vaccinationInfo: VaccinationInfo) -> Int? {
        
        if vaccinationInfo.isCurrentDoseBooster {
            return extDaysForBoosterDose(vaccinationInfo)
        }
        
        if vaccinationInfo.isCurrentDoseIncomplete {
            return extDaysForIncompleteDose(vaccinationInfo)
        }
    
        return extDaysForCompleteDose(vaccinationInfo)
        
    }
    
    
    public func getValue(for name: String, type: String) -> String? {
        return LocalData.getSetting(from: name, type: type)
    }
    
    public func getValue(for name: String) -> String? {
        return LocalData.getSetting(from: name)
    }
}

class VaccineBaseValidator: VaccineConcreteValidator {}

class VaccineReinforcedValidator: VaccineBaseValidator {}

class VaccineBoosterValidator: VaccineConcreteValidator {
    
    override func validate(hcert: HCert) -> Status {
        guard let vaccinationInfo = getVaccinationData(hcert) else { return .notValid }
        self.vaccinationInfo = vaccinationInfo
        
        if !vaccinationInfo.isEMAProduct && vaccinationInfo.isCurrentDoseIncomplete {
            return .notValid
        }
        
        let result = super.checkVaccinationInterval(vaccinationInfo)
        guard result == .valid else { return result }
        
        return checkBooster(vaccinationInfo)
    }
    
    public func checkBooster(_ vaccinationInfo: VaccinationInfo) -> Status {
        if vaccinationInfo.isCurrentDoseBooster { return . valid }
        return vaccinationInfo.isCurrentDoseComplete ? .verificationIsNeeded : .notValid
    }
    
}

class VaccineItalyEntryValidator: VaccineConcreteValidator {

    override func validate(hcert: HCert) -> Status {
        guard let vaccinationInfo = getVaccinationData(hcert) else { return .notValid }
        
        if !vaccinationInfo.isEMAProduct && vaccinationInfo.isCurrentDoseIncomplete {
            return .notValid
        }
        
        self.vaccinationInfo = vaccinationInfo
        let result = super.checkVaccinationInterval(vaccinationInfo)
        
        guard result == .valid else { return result }
        
        if !vaccinationInfo.isEMAProduct || vaccinationInfo.isCurrentDoseIncomplete {
            return .notValid
        }
        
        return result
    }
    
    public override func startDaysForCompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        let setting = Constants.vaccineCompleteStartDays_NOT_IT
        return self.getValue(for: setting)?.intValue
    }
    
    public override func endDaysForCompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        var setting = Constants.vaccineCompleteEndDays_NOT_IT
        let vaccineUnder18Offset: Int = self.getValue(for: Constants.vaccineCompleteEndDays_under_18_offset)?.intValue ?? 0
        if vaccinationInfo.isPatientUnder18(vaccineUnder18Offset: vaccineUnder18Offset) {
        	setting = Constants.vaccineCompleteEndDays_under_18
        }
        
        return self.getValue(for: setting)?.intValue
    }
    
    public override func startDaysForBoosterDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        let setting = Constants.vaccineBoosterStartDays_NOT_IT
        return self.getValue(for: setting)?.intValue
    }
    
    public override func endDaysForBoosterDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        let setting = Constants.vaccineBoosterEndDays_NOT_IT
        return self.getValue(for: setting)?.intValue
    }
    
}

class VaccineReinforcedValidatorNotItaly: VaccineReinforcedValidator {
    
    override func validate(hcert: HCert) -> Status {
        guard let vaccinationInfo = getVaccinationData(hcert) else { return .notValid }
        self.vaccinationInfo = vaccinationInfo
        
        if !vaccinationInfo.isEMAProduct && vaccinationInfo.isCurrentDoseIncomplete {
            return .notValid
        }
        
        let result = checkVaccinationInterval(vaccinationInfo)
        
        guard result == .valid else { return result }
        guard vaccinationInfo.isEMAProduct || !vaccinationInfo.isCurrentDoseIncomplete else { return .notValid }
        
        return result
    }
    
    override func validate(_ current: Date, from validityStart: Date, to validityEnd: Date, extendedTo validityEndExtension: Date) -> Status {
        switch current {
        case ..<validityStart:
            return .notValidYet
        case validityStart...validityEnd:
            if self.vaccinationInfo.isCurrentDoseIncomplete { return .valid }
            return vaccinationInfo.isEMAProduct ? .valid : .verificationIsNeeded
        case validityEnd...validityEndExtension:
            return .verificationIsNeeded
        default:
            return .expired
        }
    }
    
    public override func extDaysForCompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        return getValue(for: Constants.vaccineCompleteExtendedDays_EMA)?.intValue
    }
    
}

class VaccineBoosterValidatorNotItaly: VaccineBoosterValidator {
    
    override func validate(hcert: HCert) -> Status {
        guard let vaccinationInfo = getVaccinationData(hcert) else { return .notValid }
        self.vaccinationInfo = vaccinationInfo
        
        if !vaccinationInfo.isEMAProduct && vaccinationInfo.isCurrentDoseIncomplete {
            return .notValid
        }
        
        let result = self.checkVaccinationInterval(vaccinationInfo)
        
        guard result == .valid || result == .verificationIsNeeded else { return result }
        
        if vaccinationInfo.isCurrentDoseBooster {
            return vaccinationInfo.isEMAProduct ? .valid : .verificationIsNeeded
        }
        
        return vaccinationInfo.isCurrentDoseComplete ? .verificationIsNeeded : .notValid
    }
    
    override func validate(_ current: Date, from validityStart: Date, to validityEnd: Date, extendedTo validityEndExtension: Date) -> Status {
        let result: Status = { switch current {
        case ..<validityStart:
            return .notValidYet
        case validityStart...validityEnd:
            return vaccinationInfo.isEMAProduct ? .valid : .verificationIsNeeded
        case validityEnd...validityEndExtension:
            return .verificationIsNeeded
        default:
            return .expired
        } }()
        
        return result
    }
    
}

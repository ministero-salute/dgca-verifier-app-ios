//
//  VaccineValidators.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 01/02/22.
//

import Foundation
import SwiftDGC

class VaccineBaseValidator: DGCValidator {
    
    typealias Validator = VaccineBaseValidator
    
    private var allowedVaccinationInCountry: [String: [String]] {
        [Constants.SputnikVacineCode: [Constants.sanMarinoCode]]
    }
    
    func validate(hcert: HCert) -> Status {
        guard let preconditions = checkPreconditions(hcert) else { return .notValid }
        return checkCertificateDate(preconditions)
    }
    
    struct CertificatePreconditions {
        let currentDoses: Int
        let totalDoses: Int
        let medicalProduct: String
        let vaccineDate: Date
        let countryCode: String
        
        var isIT: Bool {
            return self.countryCode.uppercased() == Constants.ItalyCountryCode
        }
        
        var isJJ: Bool {
            return self.medicalProduct == Constants.JeJVacineCode
        }
        
        var isJJBooster: Bool {
            return self.isJJ && (self.currentDoses >= Constants.jjBoosterMinimumDosesNumber)
        }
        
        var isNonJJBooster: Bool {
            return !self.isJJ && (self.currentDoses >= Constants.boosterMinimumDosesNumber)
        }
        
        var isCurrentDoseIncomplete: Bool {
            return self.currentDoses < self.totalDoses
        }
        
        var isCurrentDoseComplete: Bool {
            return self.currentDoses == self.totalDoses && !self.isJJBooster && !self.isNonJJBooster
        }
        
        /// Valid booster dose JJ or any other
        var isCurrentDoseBooster: Bool {
            return (self.currentDoses > self.totalDoses) || (isJJBooster || self.isNonJJBooster)
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
        
        return CertificatePreconditions(currentDoses: currentDoses, totalDoses: totalDoses, medicalProduct: medicalProduct, vaccineDate: vaccineDate, countryCode: countryCode)
    }
    
    func checkCertificateDate(_ preconditions: CertificatePreconditions) -> Status {
       
        guard let start = getStartDays(preconditions: preconditions) else { return .notValid }
        guard let end = getEndDays(preconditions: preconditions) else { return .notValid }
        
        guard let validityStart = preconditions.vaccineDate.add(start, ofType: .day) else { return .notValid }
        guard let validityEnd = preconditions.vaccineDate.add(end, ofType: .day)?.startOfDay else { return .notValid }
        
        guard let currentDate = Date.startOfDay else { return .notValid }
        
        // J&J booster is immediately valid
        let fromDate = preconditions.isJJBooster ? preconditions.vaccineDate : validityStart
        
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
    
    public func getStartDays(preconditions: CertificatePreconditions) -> Int? {
        if preconditions.isCurrentDoseBooster {
            let settingName: String = preconditions.isIT ? Constants.vaccineBoosterStartDays_IT : Constants.vaccineBoosterStartDays_NOT_IT
            return self.getValue(for: settingName)?.intValue
        }
        
        if preconditions.isCurrentDoseIncomplete {
            return self.getValue(for: Constants.vaccineIncompleteStartDays, type: preconditions.medicalProduct)?.intValue
        }
    
        if preconditions.isJJ {
            let settingName = Constants.vaccineCompleteStartDays
            return self.getValue(for: settingName, type: preconditions.medicalProduct)?.intValue
        }
        let settingName =  preconditions.isIT ? Constants.vaccineCompleteStartDays_IT : Constants.vaccineCompleteStartDays_NOT_IT
        return self.getValue(for: settingName)?.intValue
    }
    
    public func getEndDays(preconditions: CertificatePreconditions) -> Int? {
        if preconditions.isCurrentDoseBooster {
            let settingName: String = preconditions.isIT ? Constants.vaccineBoosterEndDays_IT : Constants.vaccineBoosterEndDays_NOT_IT
            return self.getValue(for: settingName)?.intValue
        }
        
        if preconditions.isCurrentDoseIncomplete {
            return self.getValue(for: Constants.vaccineIncompleteEndDays, type: preconditions.medicalProduct)?.intValue
        }
    
        let settingName =  preconditions.isIT ? Constants.vaccineCompleteEndDays_IT : Constants.vaccineCompleteEndDays_NOT_IT
        return self.getValue(for: settingName)?.intValue
    }
    
    public func getValue(for name: String, type: String) -> String? {
        return LocalData.getSetting(from: name, type: type)
    }
    
    public func getValue(for name: String) -> String? {
        return LocalData.getSetting(from: name)
    
    }
    
}


class VaccineReinforcedValidator: VaccineBaseValidator {
    
    override func getStartDays(preconditions: VaccineBaseValidator.CertificatePreconditions) -> Int? {
        if preconditions.isCurrentDoseBooster {
            return self.getValue(for: Constants.vaccineBoosterStartDays_IT)?.intValue
        }
        
        if preconditions.isCurrentDoseIncomplete {
            return self.getValue(for: Constants.vaccineIncompleteStartDays, type: preconditions.medicalProduct)?.intValue
        }
        
        if preconditions.isJJ {
            let settingName = Constants.vaccineCompleteStartDays
            return self.getValue(for: settingName, type: preconditions.medicalProduct)?.intValue
        }
        return self.getValue(for: Constants.vaccineCompleteStartDays_IT)?.intValue
    }
    
    override func getEndDays(preconditions: VaccineBaseValidator.CertificatePreconditions) -> Int? {
        if preconditions.isCurrentDoseBooster {
            return self.getValue(for: Constants.vaccineBoosterEndDays_IT)?.intValue
        }
        
        if preconditions.isCurrentDoseIncomplete {
            return self.getValue(for: Constants.vaccineIncompleteEndDays, type: preconditions.medicalProduct)?.intValue
        }
        
        return self.getValue(for: Constants.vaccineCompleteEndDays_IT)?.intValue
    }
    
}


class VaccineBoosterValidator: VaccineBaseValidator {
    
    override func validate(hcert: HCert) -> Status {
        guard let preconditions = checkPreconditions(hcert) else { return .notValid }
        let result = super.checkCertificateDate(preconditions)
        
        guard result == .valid else { return result }
        return checkBooster(preconditions)
    }
    
    
    override func getStartDays(preconditions: VaccineBaseValidator.CertificatePreconditions) -> Int? {
        if preconditions.isCurrentDoseBooster {
            return self.getValue(for: Constants.vaccineBoosterStartDays_IT)?.intValue
        }
        
        if preconditions.isCurrentDoseIncomplete {
            return self.getValue(for: Constants.vaccineIncompleteStartDays, type: preconditions.medicalProduct)?.intValue
        }
        
        if preconditions.isJJ {
            let settingName = Constants.vaccineCompleteStartDays
            return self.getValue(for: settingName, type: preconditions.medicalProduct)?.intValue
        }
        return self.getValue(for: Constants.vaccineCompleteStartDays_IT)?.intValue
    }
    
    override func getEndDays(preconditions: VaccineBaseValidator.CertificatePreconditions) -> Int? {
        if preconditions.isCurrentDoseBooster {
            return self.getValue(for: Constants.vaccineBoosterEndDays_IT)?.intValue
        }
        
        if preconditions.isCurrentDoseIncomplete {
            return self.getValue(for: Constants.vaccineIncompleteEndDays, type: preconditions.medicalProduct)?.intValue
        }
        
        return self.getValue(for: Constants.vaccineCompleteEndDays_IT)?.intValue
    }
    
    private func checkBooster(_ preconditions: CertificatePreconditions) -> Status {
        if preconditions.isCurrentDoseBooster { return . valid }
        return preconditions.isCurrentDoseComplete ? .verificationIsNeeded : .notValid
    }
    
}

class VaccineSchoolValidator: VaccineBaseValidator {
    
    override func getStartDays(preconditions: VaccineBaseValidator.CertificatePreconditions) -> Int? {
        if preconditions.isCurrentDoseBooster {
            return self.getValue(for: Constants.vaccineBoosterStartDays_IT)?.intValue
        }
        
        if preconditions.isCurrentDoseIncomplete {
            return nil
        }
        
        if preconditions.isJJ {
            let settingName = Constants.vaccineCompleteStartDays
            return self.getValue(for: settingName, type: preconditions.medicalProduct)?.intValue
        }
        return self.getValue(for: Constants.vaccineCompleteStartDays_IT)?.intValue
    }
    
    override func getEndDays(preconditions: VaccineBaseValidator.CertificatePreconditions) -> Int? {
        if preconditions.isCurrentDoseBooster {
            return self.getValue(for: Constants.vaccineBoosterEndDays_IT)?.intValue
        }
        
        if preconditions.isCurrentDoseIncomplete {
            return nil
        }
        
        if preconditions.isJJ {
            let settingName = Constants.vaccineCompleteStartDays
            return self.getValue(for: settingName, type: preconditions.medicalProduct)?.intValue
        }
        return self.getValue(for: Constants.vaccineSchoolEndDays)?.intValue
    }
    
    
}

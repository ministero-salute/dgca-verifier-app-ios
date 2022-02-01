//
//  VaccineExemptionValidators.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 01/02/22.
//

import Foundation
import SwiftDGC

class VaccineExemptionBaseValidator: DGCValidator {
    
    func validate(hcert: HCert) -> Status {
        guard let exemption = hcert.vaccineExemptionStatements.last else { return .notValid }
        guard let dateFrom = exemption.dateFrom else { return .notValid }
        guard let currentDate = Date.startOfDay else { return .notValid }
        guard let dateUntil = exemption.dateUntil else {
            return VaccineExemptionBaseValidator.validate(currentDate, from: dateFrom)
        }
        return VaccineExemptionBaseValidator.validate(currentDate, from: dateFrom, to: dateUntil)
    }
 
}

class VaccineExemptionReinforcedValidator: VaccineExemptionBaseValidator {}

class VaccineExemptionBoosterValidator: VaccineExemptionBaseValidator {
    
    override func validate(hcert: HCert) -> Status {
        let baseValidation = super.validate(hcert: hcert)
        guard baseValidation == .valid else { return baseValidation }
        return .verificationIsNeeded
    }

}

class VaccineExemptionSchoolValidator: AlwaysNotValid {}


//
//  MedicalRulesValidator.swift
//  Verifier
//
//  Created by Andrea Prosseda on 28/07/21.
//

import Foundation
import SwiftDGC

struct MedicalRulesValidator: Validator {
    
    static func getStatus(from hCert: HCert) -> Status {
        switch hCert.type {
        case .test:
            let testValidityCheck = TestValidityCheck()
            return testValidityCheck.isTestValid(hCert)
        case .vaccine:
            let vaccineValidityCheck = VaccineValidityCheck()
            return vaccineValidityCheck.isVaccineDateValid(hCert)
        case .recovery:
            let recoveryValidityCheck = RecoveryValidityCheck()
            return recoveryValidityCheck.isRecoveryValid(hCert)
        case .unknown:
            return .notValid
        }
    }
    
    static func validate(_ current: Date, from validityStart: Date, to validityEnd: Date) -> Status {
        switch current {
        case ..<validityStart:
            return .notValidYet
        case validityStart...validityEnd:
            return .valid
        default:
            return .notValid
        }
    }
    
}

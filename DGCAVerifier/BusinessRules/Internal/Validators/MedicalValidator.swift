//
//  Validator.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 01/02/22.
//

import Foundation
import SwiftDGC


protocol MedicalValidatorFactory {
    func getValidator(hcert: HCert) -> MedicalValidator?
}

protocol MedicalValidator {
    static func validate(_ current: Date, from validityStart: Date) -> Status
    
    static func validate(_ current: Date, from validityStart: Date, to validityEnd: Date) -> Status
    
    static func validate(_ current: Date, from validityStart: Date, to validityEnd: Date, extendedTo validityEndExtension: Date) -> Status
    
    func validate(hcert: HCert) -> Status
}

class AlwaysNotValid: MedicalValidator {
    
    func validate(hcert: HCert) -> Status {
        return .notValid
    }
}


extension MedicalValidator {
    
    static func validate(_ current: Date, from validityStart: Date) -> Status {
        switch current {
        case ..<validityStart:
            return .notValidYet
        default:
            return .valid
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
    
    static func validate(_ current: Date, from validityStart: Date, to validityEnd: Date, extendedTo validityEndExtension: Date) -> Status {
        switch current {
        case ..<validityStart:
            return .notValidYet
        case validityStart...validityEnd:
            return .valid
        case validityEnd...validityEndExtension:
            return .valid
        default:
            return .notValid
        }
    }
        
}


struct ValidatorProducer {
    
    static func getProducer(scanMode: ScanMode) -> MedicalValidatorFactory? {
        switch scanMode {
        case .base:
            return BaseValidatorFactory()
        case .reinforced:
            return ReinforcedValidatorFactory()
        case .booster:
            return BoosterValidatorFactory()
        case .school:
            return SchoolValidatorFactory()
        case .work:
            return WorkValidatorFactory()
        }
    }
    
}


struct BaseValidatorFactory: MedicalValidatorFactory {
    
    func getValidator(hcert: HCert) -> MedicalValidator? {
        switch hcert.extendedType {
        case .unknown:
            return UnknownValidator()
        case .vaccine:
            return VaccineBaseValidator()
        case .recovery:
            return RecoveryBaseValidator()
        case .test:
            return TestBaseValidator()
        case .vaccineExemption:
            return VaccineExemptionBaseValidator()
        }
    }
    
}


struct ReinforcedValidatorFactory: MedicalValidatorFactory {
    
    func getValidator(hcert: HCert) -> MedicalValidator? {
        return nil
    }
    
}

struct BoosterValidatorFactory: MedicalValidatorFactory {
    
    func getValidator(hcert: HCert) -> MedicalValidator? {
        return nil
    }
    
}


struct SchoolValidatorFactory: MedicalValidatorFactory {
    
    func getValidator(hcert: HCert) -> MedicalValidator? {
        return nil
    }
    
}

struct WorkValidatorFactory: MedicalValidatorFactory {
    
    func getValidator(hcert: HCert) -> MedicalValidator? {
        return nil
    }
    
}





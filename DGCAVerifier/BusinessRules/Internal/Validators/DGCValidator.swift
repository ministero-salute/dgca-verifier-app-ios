//
//  Validator.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 01/02/22.
//

import Foundation
import SwiftDGC


protocol DCGValidatorFactory {
    func getValidator(hcert: HCert) -> DGCValidator?
}

protocol DGCValidator {
    func validate(_ current: Date, from validityStart: Date) -> Status
    
    func validate(_ current: Date, from validityStart: Date, to validityEnd: Date) -> Status
    
    func validate(_ current: Date, from validityStart: Date, to validityEnd: Date, extendedTo validityEndExtension: Date) -> Status
    
    func validate(hcert: HCert) -> Status
}

extension DGCValidator {
    
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
            return .notValid
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
            return .notValid
        }
    }
        
}

class AlwaysNotValid: DGCValidator {
    
    func validate(hcert: HCert) -> Status {
        return .notValid
    }
}


struct ValidatorProducer {
    
    static func getProducer(scanMode: ScanMode) -> DCGValidatorFactory? {
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
        case .italyEntry:
            return ItalyEntryValidatorFactory()
        }
    }
    
}


struct BaseValidatorFactory: DCGValidatorFactory {
    
    func getValidator(hcert: HCert) -> DGCValidator? {
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


struct ReinforcedValidatorFactory: DCGValidatorFactory {
    
    func getValidator(hcert: HCert) -> DGCValidator? {
        let isIT = hcert.countryCode == Constants.ItalyCountryCode
        switch hcert.extendedType {
        case .unknown:
            return UnknownValidator()
        case .vaccine:
            return isIT ? VaccineReinforcedValidator() : VaccineReinforcedValidatorNotItaly()
        case .recovery:
            return RecoveryReinforcedValidator()
        case .test:
            return TestReinforcedValidator()
        case .vaccineExemption:
            return VaccineExemptionReinforcedValidator()
        }
    }
    
}

struct BoosterValidatorFactory: DCGValidatorFactory {
    
    func getValidator(hcert: HCert) -> DGCValidator? {
        let isIT = hcert.countryCode == Constants.ItalyCountryCode
        switch hcert.extendedType {
        case .unknown:
            return UnknownValidator()
        case .vaccine:
            return isIT ? VaccineBoosterValidator() : VaccineBoosterValidatorNotItaly()
        case .recovery:
            return RecoveryBoosterValidator()
        case .test:
            return TestBoosterValidator()
        case .vaccineExemption:
            return VaccineExemptionBoosterValidator()
        }
    }
    
}

struct SchoolValidatorFactory: DCGValidatorFactory {
    
    func getValidator(hcert: HCert) -> DGCValidator? {
        switch hcert.extendedType {
        case .unknown:
            return UnknownValidator()
        case .vaccine:
            return VaccineSchoolValidator()
        case .recovery:
            return RecoverySchoolValidator()
        case .test:
            return TestSchoolValidator()
        case .vaccineExemption:
            return VaccineExemptionSchoolValidator()
        }
    }
    
}

struct WorkValidatorFactory: DCGValidatorFactory {
    
    func getValidator(hcert: HCert) -> DGCValidator? {
        let isIT = hcert.countryCode == Constants.ItalyCountryCode
        switch hcert.extendedType {
        case .unknown:
            return UnknownValidator()
        case .vaccine:
            return isIT ? VaccineWorkValidator() : VaccineWorkValidatorNotIt()
        case .recovery:
            return RecoveryWorkValidator()
        case .test:
            return TestWorkValidator()
        case .vaccineExemption:
            return VaccineExemptionWorkValidator()
        }
    }
    
}

struct ItalyEntryValidatorFactory: DCGValidatorFactory {
    
    func getValidator(hcert: HCert) -> DGCValidator? {
        switch hcert.extendedType {
        case .unknown:
            return UnknownValidator()
        case .vaccine:
            return VaccineItalyEntryValidator()
        case .recovery:
            return RecoveryItalyEntryValidator()
        case .test:
            return TestItalyEntryValidator()
        case .vaccineExemption:
            return VaccineExemptionItalyEntryValidator()
        }
    }
    
}



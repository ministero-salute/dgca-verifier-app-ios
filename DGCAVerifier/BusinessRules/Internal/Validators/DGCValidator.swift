//
//  Validator.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 01/02/22.
//

import Foundation
import SwiftDGC


class DGCValidatorBuilder {
    
    var checkHCert: Bool = true
    var checkBlackList: Bool = true
    var checkRevocationList: Bool = true
    var mode: ScanMode?


    func checkHCert(_ check: Bool) -> Self {
        self.checkHCert = check
        return self
    }
    
    func checkBlackList(_ check: Bool) -> Self {
        self.checkBlackList = check
        return self
    }
    
    func checkRevocationList(_ check: Bool) -> Self {
        self.checkRevocationList = check
        return self
    }
    
    func scanMode(_ mode: ScanMode) -> Self {
        self.mode = mode
        return self
    }
    
    func build(hCert: HCert) -> DGCValidator? {
        var validators: [DGCValidator] = []
        if checkHCert {
            validators.append(HCertValidator())
        }
        
        if checkBlackList {
            validators.append(BlackListValidator())
        }
        
        if (checkRevocationList) {
            validators.append(RevocationValidator())
        }

        if let scanMode = mode {
            let factory = ValidatorProducer.getProducer(scanMode: scanMode)
            if let validator = factory?.getValidator(hcert: hCert) {
                validators.append(validator)
            }
        }
        
        return ChainValidator(validators: validators)
    }
    
}


struct ChainValidator: DGCValidator {
    
    let validators: [DGCValidator]
    
    func validate(hcert: HCert) -> Status {
        guard !validators.isEmpty else { return .valid }
        let failedValidations = validators.map{ $0.validate(hcert: hcert) }.filter{$0 != .valid }
        return failedValidations.isEmpty ? .valid : failedValidations.first!
    }
    
}


protocol DCGValidatorFactory {
    func getValidator(hcert: HCert) -> DGCValidator?
}

protocol DGCValidator {
    static func validate(_ current: Date, from validityStart: Date) -> Status
    
    static func validate(_ current: Date, from validityStart: Date, to validityEnd: Date) -> Status
    
    static func validate(_ current: Date, from validityStart: Date, to validityEnd: Date, extendedTo validityEndExtension: Date) -> Status
    
    func validate(hcert: HCert) -> Status
}

extension DGCValidator {
    
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
        switch hcert.extendedType {
        case .unknown:
            return UnknownValidator()
        case .vaccine:
            return VaccineReinforcedValidator()
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
        switch hcert.extendedType {
        case .unknown:
            return UnknownValidator()
        case .vaccine:
            return VaccineBoosterValidator()
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
        return nil
    }
    
}





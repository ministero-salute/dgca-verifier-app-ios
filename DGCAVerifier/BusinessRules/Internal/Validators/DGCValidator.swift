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

class AlwaysNotValid: DGCValidator {
    
    func validate(hcert: HCert) -> Status {
        return .notValid
    }
    
    func validate(_ current: Date, from validityStart: Date) -> Status {
        return .notValid
    }
    
    func validate(_ current: Date, from validityStart: Date, to validityEnd: Date) -> Status {
        return .notValid
    }

    func validate(_ current: Date, from validityStart: Date, to validityEnd: Date, extendedTo validityEndExtension: Date) -> Status {
        return .notValid
    }
}


struct ValidatorProducer {
    
    static func getProducer(scanMode: ScanMode) -> DCGValidatorFactory? {
        switch scanMode {
        case .base:
            return BaseValidatorFactory()
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

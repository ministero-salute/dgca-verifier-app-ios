//
//  DGCValidatorBuilder.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 02/02/22.
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

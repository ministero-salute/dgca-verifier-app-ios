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
//  DGCValidatorBuilder.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 02/02/22.
//

import Foundation
import SwiftDGC

class DGCValidatorBuilder {
    
    var checkHCert: Bool 			= true
    var checkBlackList: Bool 		= true
    var checkRevocationList: Bool 	= true
	var checkTestOnly: Bool 		= false
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
	
	func checkTestOnly(_ check: Bool) -> Self {
		self.checkTestOnly = check
		return self
	}
    
    func scanMode(_ mode: ScanMode) -> Self {
        self.mode = mode
        return self
    }
    
    func build(hCert: HCert) -> DGCValidator? {
        var validators: [DGCValidator] = []
		
		if self.checkHCert {
            validators.append(HCertValidator())
        }
        
		if self.checkBlackList {
            validators.append(BlackListValidator())
        }
        
		if self.checkRevocationList {
            validators.append(RevocationValidator())
        }
		
		if self.checkTestOnly {
			validators.append(TestOnlyValidator())
		}

		if let scanMode = mode, !self.checkTestOnly {
            let factory = ValidatorProducer.getProducer(scanMode: scanMode)
            if let validator = factory?.getValidator(hcert: hCert) {
                validators.append(validator)
            }
        }
        
        return ChainValidator(validators: validators)
    }
    
}

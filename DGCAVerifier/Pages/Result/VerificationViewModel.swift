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
//  ResultViewModel.swift
//  verifier-ios
//
//

import Foundation
import SwiftDGC
import SwiftyJSON

class VerificationViewModel {
    
    var status: Status
    var hCert: HCert?
    var country: CountryModel?
    
    init(payload: String, country: CountryModel?) {
        self.country = country
        
        guard
            let scanMode = ScanMode.fetchFromLocalSettings(),
            let hCert = try? HCert(from: payload) else {
                self.status = .notGreenPass
                if VerificationState.shared.shouldValidateTestOnly() {
                    VerificationState.shared.followUpTestScanned = true
                }
                return
        }
        
        var validator: DGCValidator!
        var validatorBuilder = DGCValidatorBuilder()
        #if DEBUG
        validatorBuilder = validatorBuilder.checkHCert(false)
        #endif
        
        if VerificationState.shared.shouldValidateTestOnly() {
            print("[DEBUG MODE] Checking test only.")
            validator = validatorBuilder.checkTestOnly(true).build(hCert: hCert)
            
            VerificationState.shared.followUpTestScanned = true
        } else {
            print("[DEBUG MODE] Checking against scan mode.")
            validator = validatorBuilder.scanMode(scanMode).build(hCert: hCert)
        }
        
        self.hCert = hCert
        self.status = validator.validate(hcert: hCert)
        
        //self.hCert?.ruleCountryCode = country?.code
        //self.status = RulesValidator.getStatus(from: hCert)
        //self.test()
    }
    
    public func isPersonalDataCongruent() -> Bool {
        if VerificationState.shared.followUpTestScanned {
            return self.hCert?.fullName == VerificationState.shared.hCert?.fullName
        }
        return false
    }
    
    func getCountryName() -> String {
        return country?.name ?? "Italia"
    }
    
    private func test() {
//        self.hCert = setNewValue(to: hCert, old: "EU\\/1", new: "AU\\/1")
//        self.status = RulesValidator.getStatus(from: hCert)
    }
    
}

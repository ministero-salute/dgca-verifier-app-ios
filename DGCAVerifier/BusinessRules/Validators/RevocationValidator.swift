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
//  RevocationValidator.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 01/02/22.
//

import Foundation
import SwiftDGC

struct RevocationValidator: DGCValidator {
        
    func uvciHash(string: String) -> Data? {
        return SHA256.sha256(data: string.data(using: .utf8)!) //.hexString
    }
    
    func countryCodeUvciHash(string: String, countryCode: String) -> Data? {
        let countryCodeUvciData = (countryCode + string).data(using: .utf8)
        return SHA256.sha256(data: countryCodeUvciData!)  //.hexString
    }
    
    func validate(hcert: HCert) -> Status {
        guard DRLSynchronizationManager.shared.isSyncEnabled else { return .valid }
        
        let syncContext: SynchronizationContext = hcert.countryCode == Constants.ItalyCountryCode.uppercased() ? .IT : .EU

        if syncContext == .IT {
            let base64Hash = hcert.uvci.sha256()
            
            #if DEBUG
            return DRLDataStorage.containsIT(hash: base64Hash) ? .revokedGreenPass : .valid
            #else
            return DRLDataStorage.containsIT(hash: base64Hash) ? .notValid : .valid
            #endif
        } else {
            let hashesArray = [hcert.uvciHash?.prefix(16), hcert.signatureHash?.prefix(16), hcert.countryCodeUvciHash?.prefix(16)]
            let hashesResult = hashesArray.filter{ $0 != nil }.map{DRLDataStorage.contains(syncContext: syncContext, hash: $0?.hexString ?? "")}
            #if DEBUG
            return hashesResult.contains(true) ? .revokedGreenPass : .valid
            #else
            return hashesResult.contains(true) ? .notValid : .valid
            #endif
        }
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

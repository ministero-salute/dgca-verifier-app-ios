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
//  HCertValidator.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 01/02/22.
//

import Foundation
import SwiftDGC

struct HCertValidator: DGCValidator {
    
    func validate(hcert: HCert) -> Status {
        // cert.isValid doesn't works: it checks some medical rules too.
        guard hcert.cryptographicallyValid else { return .notValid }
        guard hcert.exp >= HCert.clock else { return .notValid }
        guard hcert.iat <= HCert.clock else { return .notValid }
        guard hcert.lastStatement != nil else { return .notValid }
        return .valid
    }
    
}

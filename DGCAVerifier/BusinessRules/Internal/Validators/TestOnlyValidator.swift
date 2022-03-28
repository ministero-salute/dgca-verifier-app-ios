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
//  TestOnlyValidator.swift
//  Verifier
//
//  Created by Johnny Bueti on 28/02/22.
//

import Foundation
import SwiftDGC

struct TestOnlyValidator: DGCValidator {
    
    func validate(hcert: HCert) -> Status {        
        return TestBaseValidator().validate(hcert: hcert)
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

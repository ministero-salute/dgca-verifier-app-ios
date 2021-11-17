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
//  HCert+Test.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 26/06/21.
//

import SwiftDGC

extension HCert {
    
    private var dateKey       : String { "sc" }
    private var resultKey     : String { "tr" }
    private var detected      : String { "260373001" }
    private var notDetected   : String { "260415000" }
    private var testTypeKey   : String { "tt" }
    private var rapidTest     : String { "LP217198-3" }
    private var molecularTest : String { "LP6464-4" }
    
    var testDate: String? {
        body["t"].array?.map{ $0[dateKey] }.first?.string
    }
    
    var testNegative: Bool? {
        testResult == notDetected
    }
    
    var testResult: String? {
        body["t"].array?.map{ $0[resultKey] }.first?.string
    }
    
    var testType: String? {
        body["t"].array?.map{ $0[testTypeKey] }.first?.string
    }
    
    var isKnownTestType: Bool {
        isMolecularTest || isRapidTest
    }
    
    var isMolecularTest: Bool {
        testType == molecularTest
    }
    
    var isRapidTest: Bool {
        testType == rapidTest
    }
    
}

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
//  HCert+Vaccine.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 25/06/21.
//

import SwiftDGC

extension HCert {
    
    private var currentDosesNumberKey       : String { "dn" }
    private var totalDosesNumberKey         : String { "sd" }
    private var medicalProductKey           : String { "mp" }
    private var dateKey                     : String { "dt" }
    private var countryCodeKey              : String { "co" }
    
    var currentDosesNumber: Int? {
        body["v"].array?.map{ $0[currentDosesNumberKey] }.first?.int
    }
    
    var totalDosesNumber: Int? {
        body["v"].array?.map{ $0[totalDosesNumberKey] }.first?.int
    }

    var medicalProduct: String? {
        body["v"].array?.map{ $0[medicalProductKey] }.first?.string
    }
    
    var vaccineDate: String? {
        body["v"].array?.map{ $0[dateKey] }.first?.string
    }
    
    var countryCode: String? {
        return body["v"].array?.map{ $0[countryCodeKey] }.first?.string
    }

}

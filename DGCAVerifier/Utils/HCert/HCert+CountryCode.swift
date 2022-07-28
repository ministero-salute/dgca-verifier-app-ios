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
//  HCert+CoutryCode.swift
//  Verifier
//
//  Created by Emilio Apuzzo on 28/07/22.
//

import Foundation
import SwiftDGC

extension HCert {
    
    private var countryCodeKey: String { "co" }

    var countryCode: String? {
        let countryCodeArray = ["v","t","r"].map{body[$0].array?.map{ $0[countryCodeKey] }.first?.string}
        let countryCode = countryCodeArray.filter{$0 != nil}.first
        return countryCode ?? nil
    }
    
}

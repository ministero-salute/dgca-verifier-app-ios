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
//  VaccineExemptionEntry.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 10/01/22.
//

import Foundation
import SwiftDGC
import SwiftyJSON


struct VaccineExemptionEntry: HCertEntry {
    
    var walletInfo: [InfoSection] {
        return []
    }
    
    var info: [InfoSection] {
        return []
    }
    
    var typeAddon: String {
        return ""
    }
    
    var validityFailures: [String] {
        return []
    }
    
    let diseaseTargeted: String
    let issuer: String
    let countryCode: String
    let uvci: String
    let dateFrom: Date?
    let dateUntil: Date?
    
    
    enum Fields: String {
        case diseaseTargeted = "tg"
        case countryCode = "co"
        case issuer = "is"
        case uvci = "ci"
        case dateFrom = "df"
        case dateUntil = "du"
    }
    
    init?(body: JSON) {
        guard
            let diseaseTargeted = body[Fields.diseaseTargeted.rawValue].string,
            let country = body[Fields.countryCode.rawValue].string,
            let issuer = body[Fields.issuer.rawValue].string,
            let uvci = body[Fields.uvci.rawValue].string,
            let df = body[Fields.dateFrom.rawValue].string
        else {
            return nil
        }
        self.diseaseTargeted = diseaseTargeted
        self.countryCode = country
        self.issuer = issuer
        self.uvci = uvci
        self.dateFrom = Date(dateString: df)
        let du = body[Fields.dateUntil.rawValue].string
        self.dateUntil = du != nil ? Date(dateString: du!) : nil
    }
    
}

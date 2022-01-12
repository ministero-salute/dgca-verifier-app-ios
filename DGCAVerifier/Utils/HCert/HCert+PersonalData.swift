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
//  HCert+PersonalData.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 27/06/21.
//

import Foundation
import SwiftDGC

extension HCert {
    
    var name: String { lastName + " " + firstName }
    
    var firstName: String { body["nam"]["gn"].string ?? "" }
    
    var lastName: String { body["nam"]["fn"].string ?? "" }
    
    var birthDate: String {
        //  TODO: use date formats to be placed inside Constants
        let dob: String = body["dob"].string ?? ""
        
        //  Date of Birth (dob) can be returned in either of the formats below.
        if dob.count == 4 {
            //  yyyy
            return dob
        } else if dob.count == 7 {
            //  yyyy-MM
            let split = dob.split(separator: "-")
            return "\(split[1])/\(split[0])"
        }
        
        //  yyyy-MM-dd
        return dob.toDate?.toDateReadableString ?? ""
    }
    
    var birthYear: Int? {
        guard let birthYear = Int(birthDate[4]) else { return nil }
        return birthYear
    }
    
}

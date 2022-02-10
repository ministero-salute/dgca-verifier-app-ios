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
    
    var name: String {
        let firstName: String = body["nam"]["gn"].string ?? ""
        let lastName: String = body["nam"]["fn"].string ?? ""
        let stdfirstName: String = body["nam"]["gnt"].string ?? ""
        let stdlastName: String = body["nam"]["fnt"].string ?? ""
        
        let fullName: String = lastName + " " + firstName
        let stdfullName: String = stdlastName + " " + stdfirstName + " " + firstName
        
        if lastName.isEmpty {
            return stdfullName
        } else {
            return fullName
        }
        
    }
    
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
        } else {
            //  yyyy-MM-dd
            let split = dob.split(separator: "-")
            return "\(split[2])/\(split[1])/\(split[0])"
        }
        
    }
    
    var birthYear: Int? {
        guard let birthYear = Int(birthDate[4]) else { return nil }
        return birthYear
    }
    
    var age: Int? {
        let dateFormatter = DateFormatter.getDefault(utc: true)
        let formats = ["yyyy", "MM/yyyy", "dd/MM/yyyy"]
        let dates: [Date] = formats.compactMap {
            dateFormatter.dateFormat = $0
            return dateFormatter.date(from: birthDate)
        }
        guard let birthdayDate = dates.first else { return nil }
        return Calendar.current.dateComponents([.year, .month, .day], from: birthdayDate, to: Date()).year
    }
    
}

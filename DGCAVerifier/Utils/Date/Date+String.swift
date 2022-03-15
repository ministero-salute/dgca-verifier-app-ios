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
//  Date+String.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 26/06/21.
//

import Foundation

extension Date {
    
    var toDateString: String {
        let df = DateFormatter.getDefault(utc: false)
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: self)
    }
    
    var toDateTimeString: String {
        let df = DateFormatter.getDefault(utc: true)
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z"
        return df.string(from: self)
    }

    var toDateReadableString: String {
        let df = DateFormatter.getDefault(utc: false)
        df.dateFormat = "dd/MM/yyyy"
        return df.string(from: self)
    }
    
    var toDateTimeReadableString: String {
        let df = DateFormatter.getDefault(utc: false)
        df.dateFormat = "dd/MM/yyyy HH:mm"
        return df.string(from: self)
    }
    
    ///	Returns the date in the following format: HH:mm, dd/MM/yyyy.
    var toTimeDateReadableString: String {
        let df = DateFormatter.getDefault(utc: false)
        df.dateFormat = "HH:mm, dd/MM/yyyy"
        return df.string(from: self)
    }

    var toTimeReadableString: String {
        let df = DateFormatter.getDefault(utc: false)
        df.dateFormat = "HH:mm:ss"
        return df.string(from: self)
    }

}

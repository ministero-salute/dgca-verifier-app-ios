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
//  HCert+Name.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 27/06/21.
//

import Foundation
import SwiftDGC

extension HCert {
    private var listItems: [InfoSection]? {
        self.info.filter { !$0.isPrivate }
    }
    var standardizedFirstName: String? {
        return listItems?.filter { $0.header == l10n("header.std-gn")}.first?.content
    }
    var standardizedLastName: String? {
        return listItems?.filter { $0.header == l10n("header.std-fn")}.first?.content
    }
    
    var firstName: String {
        return self.body["nam"]["gn"].string ?? ""
    }
    
    var lastName: String {
        return self.body["nam"]["fn"].string ?? ""
    }
}
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
//  StatementValidityCheck.swift
//  Verifier
//
//  Created by Davide Aliti on 28/10/21.
//

import Foundation

import SwiftDGC

struct StatementValidityCheck {
    
    private let blacklist = "black_list_uvci"

    func isStatementBlacklisted(_ hCert: HCert) -> Bool {
        guard let blacklist = getBlacklist() else { return false }
        return blacklist.split(separator: ";").contains("\(hCert.getUVCI())")
        
    }

    private func getBlacklist() -> String? {
        return getValue(for: blacklist)
    }

    private func getValue(for name: String) -> String? {
        return LocalData.getSetting(from: name)
    }
}


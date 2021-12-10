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
//  DebugViewModel.swift
//  VerificaC19
//
//  Created by Johnny Bueti on 07/12/21.
//

import Foundation

class DebugViewModel {
    private var publicKeys: [String]?
    
    public func getUCVICount() -> Int {
        return CRLDataStorage.crlTotalNumber()
    }
    
    public func getKIDCount() -> Int {
        return self.getPublicKeys().count
    }
    
    public func getPublicKeys() -> [String] {
        if self.publicKeys == nil {
            self.publicKeys = Array<String>(LocalData.sharedInstance.encodedPublicKeys.keys)
        }
        
        return self.publicKeys!
    }
    
    public func isDRLDownloadCompleted() -> Bool {
        return CRLDataStorage.shared.isCRLDownloadCompleted
    }
}

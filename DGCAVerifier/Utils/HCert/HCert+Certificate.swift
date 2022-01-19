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
//  HCert+Certificate.swift
//  Verifier
//
//  Created by Emilio Apuzzo on 17/12/21.
//

import Foundation
import SwiftDGC
import ASN1Decoder

extension HCert {
    
    var signedCerficate: X509Certificate? {
        let certificatesForKID = Self.publicKeyStorageDelegate?.getEncodedPublicKeys(for: self.kidStr)
        guard let certificate = certificatesForKID, !certificate.isEmpty else { return nil }
        let data: Data? = Data(base64Encoded: certificate[0])
        return try? X509Certificate(data: data ?? .init())
    }
    
}

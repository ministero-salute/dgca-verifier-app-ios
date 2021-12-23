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

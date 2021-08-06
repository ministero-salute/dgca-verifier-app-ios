//
//  Validator.swift
//  Verifier
//
//  Created by Andrea Prosseda on 28/07/21.
//

import Foundation
import SwiftDGC

protocol Validator {
    
    static func getStatus(from hCert: HCert?) -> Status
    static func getStatus(from hCert: HCert) -> Status
    
}

extension Validator {
    
    static func getStatus(from hCert: HCert?) -> Status {
        guard let hCert = hCert else { return .notGreenPass }
        guard isValid(hCert) else { return .notValid }
        return getStatus(from: hCert)
    }
    
    private static func isValid(_ hCert: HCert) -> Bool {
        // cert.isValid doesn't works: it checks some medical rules too.
        guard hCert.cryptographicallyValid else { return false }
        guard hCert.exp >= HCert.clock else { return false }
        guard hCert.iat <= HCert.clock else { return false }
        guard hCert.statement != nil else { return false }
        return true
    }

    
}

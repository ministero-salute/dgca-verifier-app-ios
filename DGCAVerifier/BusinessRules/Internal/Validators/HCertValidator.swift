//
//  HCertValidator.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 01/02/22.
//

import Foundation
import SwiftDGC

struct HCertValidator: DGCValidator {
    
    func validate(hcert: HCert) -> Status {
        // cert.isValid doesn't works: it checks some medical rules too.
        guard hcert.cryptographicallyValid else { return .notValid }
        guard hcert.exp >= HCert.clock else { return .notValid }
        guard hcert.iat <= HCert.clock else { return .notValid }
        guard hcert.lastStatement != nil else { return .notValid }
        return .valid
    }
    
}

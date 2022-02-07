//
//  UnknownValidators.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 01/02/22.
//

import Foundation
import SwiftDGC

class UnknownValidator: DGCValidator {
    
    func validate(hcert: HCert) -> Status {
        return .notValid
    }
}

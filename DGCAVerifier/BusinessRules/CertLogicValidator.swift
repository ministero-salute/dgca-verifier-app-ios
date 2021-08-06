//
//  CertLogicValidator.swift
//  Verifier
//
//  Created by Andrea Prosseda on 28/07/21.
//

import Foundation
import SwiftDGC

struct CertLogicValidator: Validator {

    static func getStatus(from hCert: HCert) -> Status {
        return .valid
    }

}

//
//  ChainValidator.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 02/02/22.
//

import Foundation
import SwiftDGC

struct ChainValidator: DGCValidator {
    
    let validators: [DGCValidator]
    
    func validate(hcert: HCert) -> Status {
        guard !validators.isEmpty else { return .valid }
        let failedValidations = validators.map{ $0.validate(hcert: hcert) }.filter{$0 != .valid }
        return failedValidations.isEmpty ? .valid : failedValidations.first!
    }
    
}

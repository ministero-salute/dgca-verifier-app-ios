//
//  RevocationValidator.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 01/02/22.
//

import Foundation
import SwiftDGC

struct RevocationValidator: DGCValidator {
    
    func validate(hcert: HCert) -> Status {
        guard CRLSynchronizationManager.shared.isSyncEnabled else { return .valid }
        let hash = hcert.getUVCI().sha256()
        guard !hash.isEmpty else { return .valid }
        return CRLDataStorage.contains(hash: hash) ? .notValid : .valid
    }
    
}

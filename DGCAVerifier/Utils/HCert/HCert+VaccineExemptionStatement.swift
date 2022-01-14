//
//  HCert+Statement.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 10/01/22.
//

import Foundation
import SwiftDGC


extension HCert {
    
    var vaccineExemptionStatements: [VaccineExemptionEntry] {
        return self.body["e"]
          .array?
          .compactMap {
            VaccineExemptionEntry(body: $0)
          } ?? []
    }
    
    var lastStatement: HCertEntry? {
        guard self.statement == nil else { return self.statement }
        guard !vaccineExemptionStatements.isEmpty else { return nil }
        return vaccineExemptionStatements.last
    }
    
}

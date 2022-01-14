//
//  HCert+Type.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 10/01/22.
//

import Foundation
import SwiftDGC


public enum HCertExtensionTypes: String {
    case test
    case vaccine
    case recovery
    case vaccineExemption
    case unknown
}

extension HCert {
    
    var extendedType: HCertExtensionTypes {
        switch self.type {
        case .recovery:
            return .recovery
        case .vaccine:
            return .vaccine
        case .test:
            return .test
        case .unknown:
            if self.vaccineExemptionStatements.isEmpty {
                return .unknown
            }
            return .vaccineExemption
        }
    }
    
}

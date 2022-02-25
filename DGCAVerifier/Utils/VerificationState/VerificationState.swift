//
//  VerificationState.swift
//  Verifier
//
//  Created by Emilio Apuzzo on 25/02/22.
//

import Foundation
import SwiftDGC

class VerificationState {
    
    static let shared = VerificationState()
    
    var hCertPayload: String?
    
    enum DoubleScanState {
        case initial
        case testScan
    }
    
}

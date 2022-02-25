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
	
	private init() {}
    
    var hCert: HCert?
	var isFollowUpScan: Bool = false

}

//
//  HCert+UVCI.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 11/01/22.
//

import Foundation
import SwiftDGC


extension HCert {
    
    func getUVCI() -> String {
        lastStatement?.uvci ?? "empty"
    }
    
}

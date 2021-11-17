//
//  Int+String.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 08/09/21.
//

import Foundation

public extension Int {
    
    var stringValue: String { String(describing: self) }
    
    var doubleValue: Double { Double(self) }

}

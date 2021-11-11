//
//  Int+Bytes.swift
//  Verifier
//
//  Created by Emilio Apuzzo on 27/10/21.
//

import Foundation

public extension Int {
    
    var toKiloBytes: Double { self.doubleValue.toKiloBytes }
    
    var toMegaBytes: Double { self.doubleValue.toMegaBytes }
    
    var byteReadableValue: String { self.doubleValue.byteReadableValue }

    var fromMegaBytesToBytes: Double { self.doubleValue.fromMegaBytesToBytes }
    
}

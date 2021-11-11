//
//  Double+Bytes.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 08/09/21.
//

import Foundation

public extension Double {
    
    var toKiloBytes: Double { self / 1024 }
    
    var toMegaBytes: Double { toKiloBytes / 1024 }
    
    var byteReadableValue: String { String(format: "%.2f", self) }

    var fromMegaBytesToBytes: Double { self * 1024 * 1024 }
    
}

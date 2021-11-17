//
//  VNObservation+Values.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 15/10/21.
//

import Foundation
import Vision

extension Array where Element == VNObservation {
    
    var allowedValues: [String] {
        self
            .compactMap { $0 as? VNBarcodeObservation }
            .filter { $0.allowedSymbology }
            .filter { $0.allowedConfidence }
            .compactMap { $0.payloadStringValue }
    }
    
}

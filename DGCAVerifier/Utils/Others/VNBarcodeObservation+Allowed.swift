//
//  VNBarcodeObservation+Allowed.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 15/10/21.
//

import Foundation
import Vision

extension VNBarcodeObservation {
    
    var allowedCodes: [VNBarcodeSymbology] { [.qr, .aztec] }
    
    var scanConfidence: VNConfidence { 0.9 }
    
    var allowedSymbology: Bool { allowedCodes.contains(self.symbology) }
    
    var allowedConfidence: Bool { self.confidence > scanConfidence }
    
}

//
//  AVCaptureDevice+Torch.swift
//  Verifier
//
//  Created by Andrea Prosseda on 13/10/21.
//

import Foundation
import AVFoundation

extension AVCaptureDevice {
    
    private static var captureDevice: AVCaptureDevice? {
        AVCaptureDevice.default(for: AVMediaType.video)
    }

    static func switchTorch() {
        guard let device = captureDevice else { return }
        enableTorch(!device.isTorchActive)
    }
    
    static func enableTorch(_ enable: Bool) {
        guard let device = captureDevice else { return }
        guard device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            enable ? on() : off()
            device.unlockForConfiguration()
        } catch {
            print("Torch can't be used")
        }
    }
    
    private static func on() {
        guard !isTorchActive else { return }
        let max = AVCaptureDevice.maxAvailableTorchLevel
        try? captureDevice?.setTorchModeOn(level: max)
    }
    
    private static func off() {
        guard isTorchActive else { return }
        captureDevice?.torchMode = .off
    }
    
    var isTorchActive: Bool {
        self.torchMode != .off
    }
    
    static var isTorchActive: Bool {
        captureDevice?.torchMode != .off
    }
    
}

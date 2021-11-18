/*
 *  license-start
 *  
 *  Copyright (C) 2021 Ministero della Salute and all other contributors
 *  
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  
 *      http://www.apache.org/licenses/LICENSE-2.0
 *  
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
*/

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

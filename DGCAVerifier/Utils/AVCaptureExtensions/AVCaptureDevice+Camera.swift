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
//  AVCaptureSession+Camera.swift
//  Verifier
//
//  Created by Andrea Prosseda on 13/10/21.
//

import Foundation
import AVFoundation
import UIKit

extension AVCaptureSession {
    
    func setup(_ delegate: AVCaptureVideoDataOutputSampleBufferDelegate, with mode: AVCaptureDevice.Position) {
        let input = getCameraInput(for: mode)
        let output = getCaptureOutput(for: delegate)
        guard let cameraInput = input else { return }
        sessionPreset = .hd1280x720
        addInput(cameraInput)
        addOutput(output)
    }
    
    func getPreviewLayer(for view: UIView) -> AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: self)
        layer.videoGravity = .resizeAspectFill
        layer.connection?.videoOrientation = .portrait
        layer.frame = view.frame
        return layer
    }
    
    func clean() {
        inputs.forEach { removeInput($0) }
        outputs.forEach { removeOutput($0) }
    }
    
    private func getCameraInput(for mode: AVCaptureDevice.Position) -> AVCaptureDeviceInput? {
        let type: AVCaptureDevice.DeviceType = .builtInWideAngleCamera
        let videoDevice = AVCaptureDevice.default(type, for: .video, position: mode)
        guard let device = videoDevice else { return nil }
        let deviceInput = try? AVCaptureDeviceInput(device: device)
        guard let input = deviceInput else { return nil }
        guard canAddInput(input) else { return nil }
        return input
    }
    
    private func getCaptureOutput(for delegate: AVCaptureVideoDataOutputSampleBufferDelegate) -> AVCaptureVideoDataOutput {
        let key = kCVPixelBufferPixelFormatTypeKey as String
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        let captureOutput = AVCaptureVideoDataOutput()
        captureOutput.videoSettings = [key: Int(kCVPixelFormatType_32BGRA)]
        captureOutput.setSampleBufferDelegate(delegate, queue: queue)
        return captureOutput
    }
    
}

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

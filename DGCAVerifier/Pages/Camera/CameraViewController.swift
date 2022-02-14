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
//  CameraViewController.swift
//  dgp-whitelabel-ios
//
//

import UIKit
import Vision
import AVFoundation
import SwiftDGC

protocol CameraCoordinator: Coordinator {
    func validate(payload: String, country: CountryModel?, delegate: CameraDelegate)
}

protocol CameraDelegate {
    func startOperations()
}

let mockQRCode = "<add your mock qr code here>"

class CameraViewController: UIViewController {
    weak var coordinator: CameraCoordinator?
    private var country: CountryModel?
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var backButton: AppButton!
    @IBOutlet weak var countryButton: AppButton!
    @IBOutlet weak var flashButton: AppButton!
    @IBOutlet weak var switchButton: UIButton!
	
	private var headerBar: HeaderBar?
	private var footerBar: FooterBar?
	
	private var captureSession = AVCaptureSession()
    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    init(coordinator: CameraCoordinator, country: CountryModel? = nil) {
        self.coordinator = coordinator
        self.country = country
        super.init(nibName: "CameraViewController", bundle: nil)
		
		self.initializeHeaderBar()
		self.initializeFooterBar()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeBackButton()
        initializeFlashButton()
        initializeCountryButton()
        #if targetEnvironment(simulator)
        found(payload: mockQRCode)
        #else
        checkPermissions()
        #endif
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRunning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startOperations()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        DispatchQueue.main.async {
            self.cameraPreviewLayer?.frame = self.cameraView.frame
        }
    }
    
    public func startOperations() {
        setupCamera()
        startRunning()
        setupFlash()
    }

    @IBAction func back(_ sender: Any) {
        coordinator?.dismiss()
    }
    
    @IBAction func flashSwitch(_ sender: Any) {
        AVCaptureDevice.switchTorch()
        Store.set(AVCaptureDevice.isTorchActive, for: .isTorchActive)
    }
    
    @objc private func flashSwitchAction() {
        AVCaptureDevice.switchTorch()
        Store.set(AVCaptureDevice.isTorchActive, for: .isTorchActive)
    }
    
    @IBAction func backToRoot(_ sender: Any) {
        coordinator?.dismissToRoot()
    }

    @IBAction func switchCamera(_ sender: Any) {
        changeCameraMode()
        setupCamera()
        startRunning()
        setupFlash()
    }
    
    @objc private func switchCameraAction() {
        changeCameraMode()
        setupCamera()
        startRunning()
        setupFlash()
    }
    
    private func found(payload: String) {
        let vc = coordinator?.navigationController.visibleViewController
        guard !(vc is VerificationViewController) else { return }
        stopRunning()
        hapticFeedback()
        let isCRLDownloadCompleted = CRLDataStorage.shared.isCRLDownloadCompleted
        let isCRLAllowed = SettingDataStorage.sharedInstance.getFirstSetting(withName: "DRL_SYNC_ACTIVE")?.boolValue ?? true
        if !isCRLDownloadCompleted && isCRLAllowed {
            showAlert(key: "no.crl.download")
            return
        }
        coordinator?.validate(payload: payload, country: country, delegate: self)
    }
	
	@objc private func goBack() {
		coordinator?.dismiss()
	}
	
	private func initializeHeaderBar() {
		self.headerBar = HeaderBar()
		self.headerBar?.backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        self.headerBar?.switchCameraButton.addTarget(self, action: #selector(switchCameraAction), for: .touchUpInside)
        self.headerBar?.flashButton.addTarget(self, action: #selector(flashSwitchAction), for: .touchUpInside)
	}
	
	private func initializeFooterBar() {
		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goBack))
		self.footerBar = FooterBar()
		self.footerBar?.closeView.addGestureRecognizer(gestureRecognizer)
	}
    
    private func initializeBackButton() {
        backButton.style = .minimal
        backButton.setLeftImage(named: "icon_back")
    }
    
    private func initializeFlashButton() {
        self.headerBar?.flashButton.cornerRadius = 30.0
        self.headerBar?.flashButton.backgroundColor = .clear
        self.headerBar?.flashButton.setImage(UIImage(named: "flash-camera"))
        self.headerBar?.flashButton.isHidden = Store.getBool(key: .isFrontCameraActive)
    }
    
    private func initializeCountryButton() {
        countryButton.style = .white
        countryButton.setRightImage(named: "icon_arrow-right")
        countryButton.setTitle(country?.name)
        countryButton.isHidden = country == nil
    }

    private func initializeCameraView() {
        cameraView.layer.backgroundColor = Palette.grayDark.cgColor
    }
    
    private func changeCameraMode() {
        let frontCameraActive = Store.getBool(key: .isFrontCameraActive)
        Store.set(!frontCameraActive, for: .isFrontCameraActive)
        self.headerBar?.flashButton.isHidden = !frontCameraActive
    }
    
    private func setupCamera() {
        cleanSession()
        captureSession.setup(self, with: currentCameraMode)
        cameraPreviewLayer = captureSession.getPreviewLayer(for: cameraView)
        cameraView.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    private func cleanSession() {
        stopRunning()
        cameraView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        captureSession.clean()
    }
    
    func setupFlash() {
        let torchActive = Store.getBool(key: .isTorchActive)
        let frontCamera = Store.getBool(key: .isFrontCameraActive)
        let enable = torchActive && !frontCamera
        AVCaptureDevice.enableTorch(enable)
    }
  
    private var currentCameraMode: AVCaptureDevice.Position {
        let isFrontCamera = Store.getBool(key: .isFrontCameraActive)
        return isFrontCamera ? .front : .back
    }
    
    private func hapticFeedback() {
        DispatchQueue.main.async {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
    
    private func showAlert(key: String) {
        let alertController = UIAlertController(
            title: "alert.\(key).title".localized,
            message: "alert.\(key).message".localized,
            preferredStyle: .alert
        )
        let alertAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.coordinator?.dismiss()
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension CameraViewController: HeaderFooterDelegate {
	public var header: UIView? {
		return self.headerBar
	}
	
	public var contentVC: UIViewController? {
		return self
	}
	
	public var footer: UIView? {
		return self.footerBar
	}
}

extension CameraViewController: CameraDelegate {

    func startRunning() {
        #if targetEnvironment(simulator)
        back(self)
        #else
        guard !captureSession.isRunning else { return }
        captureSession.startRunning()
        #endif
    }
    
    func stopRunning() {
        guard captureSession.isRunning else { return }
        captureSession.stopRunning()
    }

}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let handler = getHandler(sampleBuffer)
        try? handler?.perform([getBarcodeDetectorHandler()])
    }

    private func getHandler(_ sampleBuffer: CMSampleBuffer) -> VNImageRequestHandler? {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        return VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .right)
    }
    
    func getBarcodeDetectorHandler() -> VNDetectBarcodesRequest {
        return VNDetectBarcodesRequest { [weak self] request, error in
            guard let `self` = self else { return }
            guard error == nil else { return self.showBarcodeError(error) }
            self.processBarcodesRequest(request)
        }
    }
    func processBarcodesRequest(_ request: VNRequest) {
        guard let payload = request.results?.allowedValues.first else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.found(payload: payload)
        }
    }
}

// MARK: - Permissions
extension CameraViewController {

    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined: requestAccess()
        case .denied, .restricted: showPermissionsAlert()
        default: return
        }
    }
    
    private func requestAccess() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard !granted else { return }
            self?.showPermissionsAlert()
        }
    }
    
}

// MARK: - Alerts
extension CameraViewController {
    
    private func showPermissionsAlert() {
        let title = "alert.camera.permissions.title".localized
        let message = "alert.camera.permissions.message".localized
        showAlert(withTitle: title, message: message)
    }

    private func showCameraError() {
        let title = "alert.nocamera.title".localized
        let message = "alert.nocamera.message".localized
        showAlert(withTitle: title, message: message)
    }

    private func showBarcodeError(_ error: Error?) {
        let title = "alert.barcode.error.title".localized
        let message = error?.localizedDescription ?? "error"
        showAlert(withTitle: title, message: message)
    }
    
}

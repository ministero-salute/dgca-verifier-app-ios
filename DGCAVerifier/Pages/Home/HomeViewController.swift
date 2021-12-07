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
//  HomeViewController.swift
//  dgp-whitelabel-ios
//
//

import UIKit
import RealmSwift

typealias Tap = UITapGestureRecognizer

protocol HomeCoordinator: Coordinator {
    func showCamera()
    func showCountries()
    func openSettings()
}

class HomeViewController: UIViewController {
        
    weak var coordinator: HomeCoordinator?
    private var viewModel: HomeViewModel

    @IBOutlet weak var faqLabel: AppLabelUrl!
    @IBOutlet weak var privacyPolicyLabel: AppLabelUrl!
    @IBOutlet weak var versionLabel: AppLabelUrl!
    @IBOutlet weak var scanModeButton: AppButton!
    @IBOutlet weak var scanButton: AppButton!
    @IBOutlet weak var countriesButton: AppButton!
    @IBOutlet weak var updateNowButton: AppButton!
    
    @IBOutlet weak var lastFetchContainer: UIView!
    @IBOutlet weak var progressContainer: UIView!
    
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var lastFetchLabel: AppLabel!
    
    var sync: CRLSynchronizationManager { CRLSynchronizationManager.shared }
    let userDefaults = UserDefaults.standard

    @IBOutlet weak var settingsView: UIView!
    
    private var modePickerOptions = ["home.scan.picker.mode.2G".localized, "home.scan.picker.mode.3G".localized]
    private var modePickerView = UIPickerView()
    private var modePickerToolBar = UIToolbar()
            
    init(coordinator: HomeCoordinator, viewModel: HomeViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel

        super.init(nibName: "HomeViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.startOperations()
        subscribeEvents()
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Store.set(false, for: .isTorchActive)
        setScanModeButtonText()
    }
    
    private func initialize() {
        bindScanEnabled()
        setUpSettingsAction()
        setFAQ()
        setPrivacyPolicy()
        setVersion()
        setScanModeButton()
        setScanButton()
        setCountriesButton()
        updateLastFetch(isLoading: viewModel.isLoading.value ?? false)
        updateNowButton.contentHorizontalAlignment = .center
    }
    
    private func bindScanEnabled() {
        viewModel.isScanEnabled.add(observer: self) { [weak self] scanEnabled in
            guard let scanEnabled = scanEnabled else { return }
            if scanEnabled {
                self?.enableScanButton()
            }
            else {
                self?.disableScanButton()
            }
        }
    }

    private func setUpSettingsAction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(settingsImageDidTap))
        settingsView.addGestureRecognizer(tap)
    }
    
    private func subscribeEvents() {
        bindResults()
        bindIsLoading()
        bindShowMore()
        bindConfirmButton()
        bindResumeButton()
    }
    
    func bindResults() {
        viewModel.results.add(observer: self, { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                self?.manage(result)
            }
        })
    }
    
    func bindIsLoading() {
        viewModel.isLoading.add(observer: self, { [weak self] isLoading in
            DispatchQueue.main.async { [weak self] in
                guard let isLoading = isLoading else { return }
                self?.updateLastFetch(isLoading: isLoading)
            }
        })
    }
    
    func bindShowMore() {
        let tap = Tap(target: self, action: #selector(crlShowMore))
        progressView.showMoreLabel.add(tap)
    }
    
    func bindConfirmButton() {
        progressView.confirmButton
            .addTarget(self, action: #selector(startSync), for: .touchUpInside)
    }
     
    func bindResumeButton() {
        progressView.resumeButton
            .addTarget(self, action: #selector(resumeSync), for: .touchUpInside)
    }
    
    private func manage(_ result: HomeViewModel.Result?) {
        guard let result = result else { return }
        switch result {
        case .initializeSync:   initializeSync()
        case .updateComplete:   updateLastFetch(isLoading: false)
        case .versionOutdated:  showCustomAlert(key: "version.outdated")
        case .error(_):         lastFetchLabel.text = "error"
        }
    }
    
    private func setFAQ() {
        let title = Link.faq.title.localized
        let tap = Tap(target: self, action: #selector(faqDidTap))
        faqLabel.fillView(with: .init(text: title, onTap: tap))
    }
    
    private func setPrivacyPolicy() {
        let title = Link.privacyPolicy.title.localized
        let tap = Tap(target: self, action: #selector(privacyPolicyDidTap))
        privacyPolicyLabel.fillView(with: .init(text: title, onTap: tap))
    }
    
    private func setVersion() {
        let version = viewModel.currentVersion() ?? "?"
        versionLabel.text = "home.version".localized + " " + version
    }
    
    private func setScanModeButton() {
        setScanModeButtonStyle()
        setScanModeButtonText()
    }
    
    private func setScanModeButtonStyle() {
        scanModeButton.style = .clear
        scanModeButton.setRightImage(named: "icon_arrow-right")
    }
    
    private func setScanModeButtonText() {
        // Allows to have a multiline title label
        scanModeButton.titleLabel?.lineBreakMode = .byWordWrapping
        
        if Store.getBool(key: .isScanModeSet) {
            scanModeButton.titleLabel?.font = Font.getFont(size: 14, style: .regular)
            
            let isScanMode2G: Bool = Store.getBool(key: .isScanMode2G)
            let localizedBaseScanModeButtonTitle: String = isScanMode2G ? "home.scan.button.mode.2G".localized : "home.scan.button.mode.3G".localized
            let scanModeButtonTitle: NSMutableAttributedString = .init(string: localizedBaseScanModeButtonTitle, attributes: nil)
            let boldLocalizedText: String = isScanMode2G ? "home.scan.button.bold.2G".localized : "home.scan.button.bold.3G".localized
            let boldRange: NSRange = (scanModeButtonTitle.string as NSString).range(of: boldLocalizedText)
            
            scanModeButtonTitle.setAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)], range: boldRange)
            scanModeButton.setAttributedTitle(scanModeButtonTitle, for: .normal)
        } else {
            scanModeButton.setTitle("home.scan.button.mode.default".localized)
        }
    }
    
    private func setScanButton() {
        viewModel.isScanEnabled.value = !shouldDisableScanButton()
        scanButton.setRightImage(named: "icon_qr-code")
    }
    
    private func updateScanButtonStatus() {
        viewModel.isScanEnabled.value = !shouldDisableScanButton()
    }
    
    private func shouldDisableScanButton() -> Bool {
        let certFetch                   = LocalData.sharedInstance.lastFetch.timeIntervalSince1970
        let certFetchUpdated            = certFetch > 0

        let crlFetchOutdated            = CRLSynchronizationManager.shared.isFetchOutdated

        let isCRLDownloadCompleted      = CRLDataStorage.shared.isCRLDownloadCompleted
        let isCRLAllowed                = CRLSynchronizationManager.shared.isSyncEnabled

        let hideCondition = (viewModel.isVersionOutdated() || !Store.getBool(key: .isScanModeSet) || !certFetchUpdated || (isCRLAllowed && (crlFetchOutdated || !isCRLDownloadCompleted)))
        return hideCondition
    }
    
    private func setCountriesButton() {
        countriesButton.style = .clear
        countriesButton.setRightImage(named: "icon_arrow-right")
    }
    
    func initializeSync() {
        CRLSynchronizationManager.shared.initialize(delegate: self)
    }
    
    private func updateLastFetch(isLoading: Bool) {
        guard !isLoading else { return lastFetchLabel.text = "home.loading".localized }
        let date = viewModel.getLastUpdate()?.toDateTimeReadableString
        lastFetchLabel.text = date == nil ? "home.not.available".localized : date
    }

    @objc func faqDidTap() {
        guard let url = URL(string: Link.faq.url) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func privacyPolicyDidTap() {
        guard let url = URL(string: Link.privacyPolicy.url) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func settingsImageDidTap() {
        coordinator?.openSettings()
    }

    @objc func goToStore(_ action: UIAlertAction? = nil) {
        guard let url = URL(string: Link.store.url) else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func crlShowMore() {
        sync.showCRLUpdateAlert()
    }
    
    @objc func startSync() {
        guard Connectivity.isOnline else {
            showAlert(key: "no.connection")
            return
        }
        
        if sync.noPendingDownload || sync.needsServerStatusUpdate {
            sync.start()
        } else {
            sync.download()
        }
    }
    
    @objc func resumeSync() {
        guard Connectivity.isOnline else {
            showAlert(key: "no.connection")
            return
        }
        sync.download()
    }

    private func showAlert(key: String) {
        let alertController = UIAlertController(
            title: "alert.\(key).title".localized,
            message: "alert.\(key).message".localized,
            preferredStyle: .alert
        )
        alertController.addAction(.init(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func showCustomAlert(key: String) {
        AppAlertViewController.present(for: self, with: .init(
            title: "alert.\(key).title".localized,
            message: "alert.\(key).message".localized,
            confirmAction: {},
            confirmActionTitle: "alert.default.action".localized,
            cancelAction: {},
            cancelActionTitle: nil))
    }
    
    private func disableScanButton(){
        scanButton.style = .disabled
        scanButton.alpha = 0.8
    }

    public func enableScanButton() {
        scanButton.style = .blue
        scanButton.alpha = 1
    }
    
    @IBAction func scanModeButtonTapped(_ sender: Any) {
        modeViewDidTap()
    }
    
    @IBAction func scan(_ sender: Any) {
        guard !viewModel.isVersionOutdated() else { return showCustomAlert(key: "version.outdated") }
                
        let certFetch                   = LocalData.sharedInstance.lastFetch.timeIntervalSince1970
        let certFetchUpdated            = certFetch > 0
        
        let crlFetchOutdated            = CRLSynchronizationManager.shared.isFetchOutdated
        
        let isCRLDownloadCompleted      = CRLDataStorage.shared.isCRLDownloadCompleted
        let isCRLAllowed                = CRLSynchronizationManager.shared.isSyncEnabled
        
        guard Store.getBool(key: .isScanModeSet) else { return showCustomAlert(key: "scan.unset") }
        
        guard certFetchUpdated else {
            showCustomAlert(key: "no.keys")
            return
        }
        
        if isCRLAllowed {
            guard !crlFetchOutdated else {
                showCustomAlert(key: "crl.outdated")
                return
            }
            guard isCRLDownloadCompleted else {
                showCustomAlert(key: "crl.update.resume")
                return
            }
        }
        
        coordinator?.showCamera()
    }
    
    @IBAction func chooseCountry(_ sender: Any) {
        guard !viewModel.isVersionOutdated() else { return showCustomAlert(key: "version.outdated") }
    }
    
    @IBAction func updateNow(_ sender: Any) {
        let isLoading = viewModel.isLoading.value ?? false
        guard !isLoading else { return }
        viewModel.startOperations()
    }
    
    private func showNotAvailable() {
        lastFetchLabel.text = "home.not.available".localized
    }
    
    private func crlDownloadNeeded() {
        progressView.fillView(with: sync.progress)
        showCRL(true)
    }
    
    private func showDownloadingProgress() {
        updateScanButtonStatus()
        progressView.downloading(with: sync.progress)
        showCRL(true)
    }
    
    private func downloadCompleted() {
        updateScanButtonStatus()
        showCRL(false)
    }
    
    private func downloadPaused() {
        updateScanButtonStatus()
        progressView.pause(with: sync.progress)
        showCRL(true)
    }
    
    private func downloadError() {
        updateScanButtonStatus()
        progressView.error(with: sync.progress)
        showCRL(true)
    }
    
    private func networkStatusError() {
        updateScanButtonStatus()
        progressView.error(with: sync.progress, noSize: true)
        showCRL(true)
    }
    
    private func showCRL(_ value: Bool) {
        lastFetchContainer.isHidden = value
        progressContainer.isHidden = !value
    }
    
}

extension HomeViewController: CRLSynchronizationDelegate {
    
    func statusDidChange(with result: CRLSynchronizationManager.Result) {
        switch result {
        case .downloadReady:        crlDownloadNeeded()
        case .downloading:          showDownloadingProgress()
        case .completed:            downloadCompleted()
        case .paused:               downloadPaused()
        case .error:                downloadError()
        case .statusNetworkError:   networkStatusError()
        }
    }
}

extension HomeViewController {
    
    func modeViewDidTap() {
        PickerViewController.present(for: self, with: .init(
            headerTitle: "home.scan.picker.title".localized,
            doneButtonTitle: "label.done".localized,
            cancelButtonTitle: nil,
            pickerOptions: self.modePickerOptions,
            selectedOption: Store.getBool(key: .isScanMode2G) ? 0 : 1,
            doneCallback: self.didModeTapDone,
            cancelCallback: nil,
            tapAnywhereToDismissEnabled: false
        ))
    }
    
    private func didModeTapDone(vc: PickerViewController) {
        let selectedRow: Int = vc.selectedRow()
        
        vc.selectRow(selectedRow, animated: false)
        Store.set(true, for: .isScanModeSet)
        Store.set(selectedRow == 0, for: .isScanMode2G)
        
        setScanModeButton()
        updateScanButtonStatus()
    }
    
}

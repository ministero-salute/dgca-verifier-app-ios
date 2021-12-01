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
    
    @IBOutlet weak var lastFetchLabel: AppLabel!
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
        initialize()
        viewModel.startOperations()
        subscribeEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Store.set(false, for: .isTorchActive)
        setScanModeButtonText()
    }
    
    private func initialize() {
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

    private func setUpSettingsAction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(settingsImageDidTap))
        settingsView.addGestureRecognizer(tap)
    }
    
    private func subscribeEvents() {
        viewModel.results.add(observer: self, { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                self?.manage(result)
            }
        })
        
        viewModel.isLoading.add(observer: self, { [weak self] isLoading in
            DispatchQueue.main.async { [weak self] in
                guard let isLoading = isLoading else { return }
                self?.updateLastFetch(isLoading: isLoading)
            }
        })
    }
    
    private func manage(_ result: HomeViewModel.Result?) {
        guard let result = result else { return }
        switch result {
        case .updateComplete:       updateLastFetch(isLoading: false)
        case .versionOutdated:      showOutdatedAlert()
        case .error(_):             lastFetchLabel.text = "error"
        }
    }
    
    private func setFAQ() {
        let title = Link.faq.title.localized
        let tap = UITapGestureRecognizer(target: self, action: #selector(faqDidTap))
        faqLabel.fillView(with: .init(text: title, onTap: tap))
    }
    
    private func setPrivacyPolicy() {
        let title = Link.privacyPolicy.title.localized
        let tap = UITapGestureRecognizer(target: self, action: #selector(privacyPolicyDidTap))
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
        scanButton.style = .blue
        scanButton.setRightImage(named: "icon_qr-code")
    }
    
    private func setCountriesButton() {
        countriesButton.style = .clear
        countriesButton.setRightImage(named: "icon_arrow-right")
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
    
    private func showOutdatedAlert() {
        let alert = UIAlertController(title: "alert.version.outdated.title".localized, message: "alert.version.outdated.message".localized, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: goToStore))
        present(alert, animated: true, completion: nil)
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
    
    @IBAction func scanModeButtonTapped(_ sender: Any) {
        modeViewDidTap()
    }
    
    @IBAction func scan(_ sender: Any) {
        guard !viewModel.isVersionOutdated() else { return showOutdatedAlert() }
        
        guard Store.getBool(key: .isScanModeSet) else {
            let alert = UIAlertController(
                title: "alert.default.error.title".localized,
                message: "alert.scan.unset.message".localized,
                preferredStyle: .alert
            )
            alert.addAction(.init(title: "alert.default.action".localized, style: .default, handler: nil))
            present(alert, animated: true, completion: nil)

            return

        }
        
        let lastFetch = LocalData.sharedInstance.lastFetch.timeIntervalSince1970
        lastFetch > 0 ? coordinator?.showCamera() : showAlert(key: "no.keys")
    }
    
    @IBAction func chooseCountry(_ sender: Any) {
        guard !viewModel.isVersionOutdated() else { return showOutdatedAlert() }
    }
    
    @IBAction func updateNow(_ sender: Any) {
        let isLoading = viewModel.isLoading.value ?? false
        guard !isLoading else { return }
        viewModel.startOperations()
    }
}

extension HomeViewController {
    
    func modeViewDidTap() {
        PickerViewController.present(for: self, with: .init(
            doneButtonTitle: "label.done".localized,
            cancelButtonTitle: "label.cancel".localized,
            pickerOptions: self.modePickerOptions,
            selectedOption: Store.getBool(key: .isScanMode2G) ? 0 : 1,
            doneCallback: self.didModeTapDone,
            cancelCallback: nil
        ))
    }
    
    private func didModeTapDone(vc: PickerViewController) {
        let selectedRow: Int = vc.selectedRow()
        
        vc.selectRow(selectedRow, animated: false)
        Store.set(true, for: .isScanModeSet)
        Store.set(selectedRow == 0, for: .isScanMode2G)
        
        setScanModeButton()
    }
    
}

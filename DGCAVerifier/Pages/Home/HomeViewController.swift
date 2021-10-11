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
}

class HomeViewController: UIViewController {
    
    weak var coordinator: HomeCoordinator?
    private var viewModel: HomeViewModel

    @IBOutlet weak var faqLabel: AppLabelUrl!
    @IBOutlet weak var privacyPolicyLabel: AppLabelUrl!
    @IBOutlet weak var versionLabel: AppLabelUrl!
    @IBOutlet weak var scanButton: AppButton!
    @IBOutlet weak var countriesButton: AppButton!
    @IBOutlet weak var updateNowButton: AppButton!
    
    @IBOutlet weak var lastFetchLabel: AppLabel!
    
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
    
    private func initialize() {
        setFAQ()
        setPrivacyPolicy()
        setVersion()
        setScanButton()
        setCountriesButton()
        updateLastFetch(isLoading: viewModel.isLoading.value ?? false)
        updateNowButton.contentHorizontalAlignment = .center
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

    @objc func goToStore(_ action: UIAlertAction? = nil) {
//        guard let url = URL(string: Link.store.url) else { return }
//        guard UIApplication.shared.canOpenURL(url) else { return }
//        UIApplication.shared.open(url)
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
    
    @IBAction func scan(_ sender: Any) {
        guard !viewModel.isVersionOutdated() else { return showOutdatedAlert() }
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

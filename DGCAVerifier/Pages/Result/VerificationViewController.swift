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
//  ResultViewController.swift
//  dgp-whitelabel-ios
//
//

import UIKit
import RealmSwift

protocol VerificationCoordinator: Coordinator {
    func dismissVerification(animated: Bool, completion: (()->())?)
}

class VerificationViewController: UIViewController {
        
    private weak var coordinator: VerificationCoordinator?
    private var delegate: CameraDelegate?
    private var viewModel: VerificationViewModel
    
    @IBOutlet weak var resultImageHeight: NSLayoutConstraint!
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var tickStackView: UIStackView!
    @IBOutlet weak var buttonStackView: UIStackView!
    
    @IBOutlet weak var lastFetchLabel: AppLabel!
    @IBOutlet weak var titleLabel: AppLabel!
    @IBOutlet weak var descriptionLabel: AppLabel!
    @IBOutlet weak var closeView: UIStackView!

    @IBOutlet weak var faqStackView: UIStackView!
    @IBOutlet weak var personalDataStackView: UIStackView!
    
    @IBOutlet weak var modeLabel: AppLabel!
    
    var timer: Timer?
    
    private var headerBar: HeaderBar?
    
    init(coordinator: VerificationCoordinator, delegate: CameraDelegate, viewModel: VerificationViewModel) {
        self.coordinator = coordinator
        self.delegate = delegate
        self.viewModel = viewModel
        
        super.init(nibName: "VerificationViewController", bundle: nil)
        
        self.initializeHeaderBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViews()
        #if targetEnvironment(simulator)
        let status: Status = .verificationIsNeeded
        validate(status)
        #else
        validate(viewModel.status)
        #endif
        
        setupTickView(viewModel.status)
        
        VerificationState.shared.userCanceledSecondScan = false
    }
        
    func setupTickView(_ status: Status) {
        tickStackView.removeAllArrangedSubViews()
        buttonStackView.removeAllArrangedSubViews()

        if !VerificationState.shared.followUpTestScanned {
            guard status == .verificationIsNeeded else { return }
            addSecondScanButton()
        } else if VerificationState.shared.isFollowUpScan && status != .notGreenPass {
            addTickView(status)
        }
    }
    
    private func addSecondScanButton() {
        
        let secondScanButton = AppButton()
        let noTestAvailableButton = AppButton()
        
        secondScanButton.setRightImage(named: "icon_qr-code")
        secondScanButton.setTitle("result.scan.button.second".localized)
        secondScanButton.addTarget(self, action: #selector(self.secondScanDidTap), for: .touchUpInside)
        
        noTestAvailableButton.setTitle("result.scan.button.no.test".localized)
        noTestAvailableButton.setTitleColor(Palette.blue, for: .normal)
        noTestAvailableButton.style = .white
        noTestAvailableButton.setRightImage(named: "close")
        noTestAvailableButton.addTarget(self, action: #selector(self.noTestAvailableDidTap), for: .touchUpInside)
        
        buttonStackView.addArrangedSubview(secondScanButton)
        buttonStackView.addArrangedSubview(noTestAvailableButton)
    }
    
    private func addTickView(_ status: Status) {
        let firstScanView = VerificationTickView()
        let secondScanView = VerificationTickView()
        let personalDataCheckView = VerificationTickView()

        let iconValid = UIImage(named: "icon_valid")
        let iconNotValid = UIImage(named: "icon_not-valid")
        
        firstScanView.tickImageView.image = iconValid
        firstScanView.tickLabel.text = "result.tick.valid".localized
        
        if self.viewModel.isPersonalDataCongruent() {
            personalDataCheckView.tickImageView.image = iconValid
            personalDataCheckView.tickLabel.text = "result.tick.congruent.personal.data".localized
        } else {
            personalDataCheckView.tickImageView.image = iconNotValid
            personalDataCheckView.tickLabel.text = "result.tick.not.congruent.personal.data".localized
        }
        
        switch status {
        case .valid:
            secondScanView.tickImageView.image = iconValid
            secondScanView.tickLabel.text = "result.tick.test.valid".localized
        default:
            secondScanView.tickImageView.image = iconNotValid
            secondScanView.tickLabel.text = "result.tick.test.not.valid".localized
        }
        
        tickStackView.addArrangedSubview(firstScanView)
        tickStackView.addArrangedSubview(secondScanView)
        if status == .valid && !self.viewModel.isPersonalDataCongruent() {
            tickStackView.addArrangedSubview(personalDataCheckView)
        }
    }
    
    private func validate(_ status: Status) {
        var statusWithValidIdentity: Status = status
        if VerificationState.shared.followUpTestScanned && !self.viewModel.isPersonalDataCongruent() && status != .notGreenPass {
            statusWithValidIdentity = .notValid
        }
        
        view.backgroundColor = statusWithValidIdentity.backgroundColor
        resultImageView.image = statusWithValidIdentity.mainImage
        if VerificationState.shared.followUpTestScanned {
            titleLabel.text = statusWithValidIdentity.secondScanTitle.localizeWith(getTitleArguments(statusWithValidIdentity))
        } else {
            titleLabel.text = statusWithValidIdentity.title.localizeWith(getTitleArguments(statusWithValidIdentity))
        }
        descriptionLabel.text = statusWithValidIdentity.description?.localized
        descriptionLabel.sizeToFit()
        lastFetchLabel.isHidden = !statusWithValidIdentity.showLastFetch
        setFaq(for: statusWithValidIdentity)
        setPersonalData(for: statusWithValidIdentity)
        setTimerIfNeeded(for: statusWithValidIdentity)
        
        if status == .verificationIsNeeded {
            VerificationState.shared.hCert = self.viewModel.hCert
        }
    }
    
    private func setFaq(for status: Status) {
        faqStackView.removeAllArrangedSubViews()
        faqStackView.addArrangedSubview(getFaq(for: status))
    }
    
    private func setPersonalData(for status: Status) {
        personalDataStackView.superview?.isHidden = true
        personalDataStackView.removeAllArrangedSubViews()
        guard status.showPersonalData else { return }
        guard let cert = viewModel.hCert else { return }
        guard !cert.name.isEmpty else { return }
        guard !cert.birthDateString.isEmpty else { return }
        let name = getResult(cert.name, for: "result.name")
        let birthDate = getResult(cert.birthDateString, for: "result.birthdate")
        personalDataStackView.addArrangedSubview(name)
        personalDataStackView.addArrangedSubview(birthDate)
        personalDataStackView.superview?.isHidden = false
    }

    private func initializeViews() {
        setLastFetch()
        setCard()
        setCloseView()
        setScanMode()
        resultImageHeight.constant *= Font.scaleFactor
    }
    
    private func getResult(_ description: String, for title: String) -> ResultView {
        let view = ResultView()
        view.fillView(with: .init(title: title, description: description))
        return view
    }
    
    private func getFaq(for status: Status) -> FaqView {
        let view = FaqView()
        let tap = UrlTapGesture(target: self, action: #selector(faqDidTap))
        tap.url = status.faqSettingsLink
        let title = status.faqSettingsTitle
        view.fillView(with: .init(text: title, onTap: tap))
        
        return view
    }
    
    private func getTitleArguments(_ status: Status) -> [CVarArg] {
        guard status.showCountryName else { return [] }
        return [viewModel.getCountryName()]
    }
    
    @objc func faqDidTap(recognizer: UrlTapGesture) {
        guard let url = URL(string: recognizer.url ?? "") else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func dismissVC() {
        if VerificationState.shared.followUpTestScanned {
            //    End of second scan path: reset VerificationState.
            VerificationState.shared.reset()
        }
        
        hapticFeedback()
        timer?.invalidate()
        coordinator?.dismissVerification(animated: !VerificationState.shared.isFollowUpScan, completion: nil)
        delegate?.startOperations()
    }
    
    @objc func secondScanDidTap() {
        print("[DEBUG MODE] Second scan tapped.")
        
        VerificationState.shared.isFollowUpScan = true
        self.dismissVC()
    }
    
    @objc func noTestAvailableDidTap() {
        print("[DEBUG MODE] No test available tapped.")
        
        self.viewModel.status = .notValid
        VerificationState.shared.isFollowUpScan = true
        VerificationState.shared.followUpTestScanned = true
        
        UIView.transition(with: self.view, duration: 0.33,
                          options: [.curveEaseOut],
                          animations: { self.viewDidLoad() },
                          completion: nil
        )
    }
    
    private func setScanMode() {
        modeLabel.textColor = Palette.white
        
        let scanMode: String = Store.get(key: .scanMode) ?? ""
        var mode: String = ""
        
        switch scanMode{
        case Constants.scanMode2G:
            mode = "result.scan.mode.2G".localized
        case Constants.scanMode3G:
            mode = "result.scan.mode.3G".localized
        case Constants.scanModeBooster:
            mode = "result.scan.mode.Boster".localized
        default:
            break
        }
        
        modeLabel.text = mode
    }
    
    private func setLastFetch() {
        let text = "result.last.fetch".localized + " "
        let date = Date().toTimeDateReadableString
        lastFetchLabel.text = text + date
    }
    
    private func setCard() {
        let cardView = view.subviews.first
        cardView?.cornerRadius = 4
        cardView?.addShadow()

    }
    
    private func setCloseView() {
        self.closeView.isHidden = false
        
        guard self.viewModel.status != .verificationIsNeeded else {
            self.closeView.isHidden = true
            return
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        closeView.addGestureRecognizer(tap)
    }
    
    private func hapticFeedback() {
        DispatchQueue.main.async {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
    
    private func setTimerIfNeeded(for status: Status) {
        let isTotemModeActive = Store.getBool(key: .isTotemModeActive)
        guard isTotemModeActive else { return }
        guard status.isValidState else { return }
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(dismissVC), userInfo: nil, repeats: false)
    }
    
    private func initializeHeaderBar() {
        self.headerBar = HeaderBar()
        self.headerBar?.flashButton.isHidden = true
        self.headerBar?.switchCameraButton.isHidden = true
    }
}

extension VerificationViewController: HeaderFooterDelegate {
    public var header: UIView? {
        return self.headerBar
    }
    
    public var contentVC: UIViewController? {
        return self
    }
    
    public var footer: UIView? {
        return nil
    }
}

class UrlTapGesture: UITapGestureRecognizer {
    var url: String?
}

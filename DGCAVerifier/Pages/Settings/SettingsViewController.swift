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
//  SettingsViewController.swift
//  Verifier
//
//  Created by Emilio Apuzzo on 07/10/21.
//

import UIKit

protocol SettingsCoordinator: Coordinator {
    func dismissSettings(completion: (()->())?)
}

protocol SettingsDelegate {
    func goToFAQ()
    func goToPrivacy()
}

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var backButton: AppButton!
    @IBOutlet weak var titleLabel: AppLabel!
    @IBOutlet weak var preferencesLabel: AppLabel!
    @IBOutlet weak var informationsLabel: AppLabel!
    @IBOutlet weak var modeView: AppShadowView!
    @IBOutlet weak var modeLabel: AppLabel!
    @IBOutlet weak var modeValueLabel: AppLabel!
    @IBOutlet weak var faqView: AppShadowView!
    @IBOutlet weak var faqLabel: AppLabel!
    @IBOutlet weak var privacyView: AppShadowView!
    @IBOutlet weak var privacyLabel: AppLabel!
    
    weak var coordinator: SettingsCoordinator?
    private var viewModel: SettingsViewModel
    
    private var pickerViewOptions = ["settings.mode.automatic".localized, "settings.mode.manual".localized]
    private var pickerView = UIPickerView()
    private var pickerToolBar = UIToolbar()
    
    let UDKeyTotemIsActive = "IsTotemModeActive"
    let userDefaults = UserDefaults.standard
    
    var UDIsTotemModeActive: Bool {
        return userDefaults.bool(forKey: UDKeyTotemIsActive)
    }
    
    init(coordinator: SettingsCoordinator, viewModel: SettingsViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel

        super.init(nibName: "SettingsViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeBackButton()
        setUpTitle()
        setUpModeView()
        setUpFAQView()
        setUpPrivacyView()
        setUpViewActions()
    }
    
    private func initializeBackButton() {
        backButton.style = .minimal
        backButton.setLeftImage(named: "icon_back")
    }
    
    private func setUpTitle(){
        titleLabel.text = "settings.title".localized
        titleLabel.font = .boldSystemFont(ofSize: 15)
        preferencesLabel.text = "settings.preferences".localized
        informationsLabel.text = "settings.informations".localized
    }
    
    private func setUpModeView(){
        modeLabel.text = "settings.mode".localized
        modeValueLabel.text = (self.UDIsTotemModeActive == true) ? "settings.mode.automatic".localized : "settings.mode.manual".localized
        modeLabel.font = .boldSystemFont(ofSize: 15)
    }
    
    private func setUpFAQView(){
        faqLabel.text = "settings.faq".localized
        faqLabel.font = .boldSystemFont(ofSize: 15)
    }
    
    private func setUpPrivacyView(){
        privacyLabel.text = "settings.privacy".localized
        privacyLabel.font = .boldSystemFont(ofSize: 15)
    }
    
    private func setUpViewActions(){
        let faqTapGesture = UITapGestureRecognizer(target: self, action: #selector(faqDidTap))
        faqView.addGestureRecognizer(faqTapGesture)
        let privacyTapGesture = UITapGestureRecognizer(target: self, action: #selector(privacyPolicyDidTap))
        privacyView.addGestureRecognizer(privacyTapGesture)
        let pickerModeTapGesture = UITapGestureRecognizer(target: self, action: #selector(modeViewDidTap))
        modeView.addGestureRecognizer(pickerModeTapGesture)
    }
    
    @IBAction func goBack(_ sender: Any) {
        coordinator?.dismissSettings(completion: nil)
    }
    
    @objc func faqDidTap(_ sender: UITapGestureRecognizer) {
        guard let url = URL(string: Link.faq.url) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func privacyPolicyDidTap(_ sender: UITapGestureRecognizer) {
        guard let url = URL(string: Link.privacyPolicy.url) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func modeViewDidTap(_ sender: UITapGestureRecognizer) {
        
        pickerView = UIPickerView(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 300))
        pickerView.backgroundColor = .white

        pickerView.showsSelectionIndicator = true
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        
        let automatic = userDefaults.bool(forKey: UDKeyTotemIsActive)
        pickerView.selectRow(automatic ? 0 : 1, inComponent: 0, animated: false)
        self.view.addSubview(pickerView)
        
        pickerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pickerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pickerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        pickerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        
        pickerToolBar = UIToolbar(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 100))
        pickerToolBar.barStyle = UIBarStyle.default
        pickerToolBar.isTranslucent = true
        pickerToolBar.tintColor = .black

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.didTapDone))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.didTapCancel))

        pickerToolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        pickerToolBar.isUserInteractionEnabled = true
        
        self.view.addSubview(pickerToolBar)

        pickerToolBar.translatesAutoresizingMaskIntoConstraints = false
        pickerToolBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pickerToolBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pickerToolBar.bottomAnchor.constraint(equalTo: pickerView.topAnchor).isActive = true
        pickerToolBar.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    @objc func didTapDone() {
        let row = self.pickerView.selectedRow(inComponent: 0)
        self.pickerView.selectRow(row, inComponent: 0, animated: false)
        self.modeValueLabel.text = self.pickerViewOptions[row]
        if row == 0 {
            userDefaults.set(true, forKey: UDKeyTotemIsActive)
        }
        else if row == 1{
            userDefaults.set(false, forKey: UDKeyTotemIsActive)
        }
        removePicker()
    }

    @objc func didTapCancel() {
        removePicker()
    }
    
    private func removePicker(){
        pickerToolBar.removeFromSuperview()
        pickerView.removeFromSuperview()
    }
    
}

extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return pickerViewOptions.count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            switch row {
            case 0: //Automatic
                self.modeValueLabel.text = self.pickerViewOptions[row]
                userDefaults.set(true, forKey: UDKeyTotemIsActive)
                return
            case 1: //Manual
                self.modeValueLabel.text = self.pickerViewOptions[row]
                userDefaults.set(false, forKey: UDKeyTotemIsActive)
                return
            default:
                return
            }
        } else {
            return
        }
    }
}

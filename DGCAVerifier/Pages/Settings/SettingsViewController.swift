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
    func openWebURL(url: URL)
}

protocol SettingsDelegate {
    func goToFAQ()
    func goToPrivacy()
}

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var backButton: AppButton!
    @IBOutlet weak var tableView: UITableView!
    
    weak var coordinator: SettingsCoordinator?
    private var viewModel: SettingsViewModel
    
    private var modePickerOptions = ["settings.mode.automatic".localized, "settings.mode.manual".localized]
    private var modePickerView = UIPickerView()
    private var modePickerToolBar = UIToolbar()
    
    private let informationsSettings = ["settings.faq".localized, "settings.privacy".localized]

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
        initializeTaleView()
    }
    
    private func initializeTaleView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        tableView.backgroundView?.backgroundColor = .white
        
        tableView.registerNibCell(ofType: SettingsCell.self, with: "SettingsCell")
        tableView.registerNibCell(ofType: SettingsHeaderCell.self, with: "SettingsHeaderCell")
    }
    
    private func initializeBackButton() {
        backButton.style = .minimal
        backButton.setLeftImage(named: "icon_back")
    }
    
    @IBAction func goBack(_ sender: Any) {
        coordinator?.dismissSettings(completion: nil)
    }
    
    func modeViewDidTap() {
        PickerViewController.present(for: self, with: .init(
            doneButtonTitle: "label.done".localized,
            cancelButtonTitle: "label.cancel".localized,
            pickerOptions: self.modePickerOptions,
            selectedOption: Store.getBool(key: .isTotemModeActive) ? 0 : 1,
            doneCallback: self.didModeTapDone,
            cancelCallback: nil
        ))
    }
    
    func faqDidTap() {
        guard let url = URL(string: Link.faq.url) else { return }
        coordinator?.openWebURL(url: url)
    }
    
    func privacyPolicyDidTap() {
        guard let url = URL(string: Link.privacyPolicy.url) else { return }
        coordinator?.openWebURL(url: url)
    }
    
    private func didModeTapDone(vc: PickerViewController) {
        let selectedRow: Int = vc.selectedRow()
        
        vc.selectRow(selectedRow, animated: false)
        Store.set(selectedRow == 0, for: .isTotemModeActive)
        tableView.reloadData()
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
            
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 1
        case 4:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as? SettingsCell else {return UITableViewCell()}
                
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "SettingsHeaderCell", for: indexPath) as? SettingsHeaderCell else {return UITableViewCell()}
                
        switch indexPath.section{
        case 0 :
            headerCell.fillCell(title: "settings.title".localized, isSeparatorHidden: false)
            return headerCell
        case 1:
            headerCell.fillCell(title: "settings.preferences".localized, fontSize: 13)
            return headerCell
        case 2:
            switch indexPath.row{
            case 0:
                let value = Store.getBool(key: .isTotemModeActive)
                let valueString = value ? "settings.mode.automatic".localized : "settings.mode.manual".localized
                cell.fillCell(title: "settings.mode".localized, icon: "pencil", value: valueString)
                return cell
            default:
                break
            }
        case 3:
            headerCell.fillCell(title: "settings.informations".localized, fontSize: 13)
            return headerCell
        case 4:
            cell.fillCell(title: informationsSettings[indexPath.row], icon: "icon_arrow-right", value: nil)
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section{
        case 2:
            switch indexPath.row{
            case 0:
                modeViewDidTap()
            default:
                break
            }
        case 4:
            switch indexPath.row{
            case 0:
                faqDidTap()
            case 1:
                privacyPolicyDidTap()
            default:
                break
            }
        default:
            break
        }
    }
    
}

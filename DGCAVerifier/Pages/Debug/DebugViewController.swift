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
//  DebugViewController.swift
//  VerificaC19
//
//  Created by Johnny Bueti on 07/12/21.
//

import UIKit

protocol DebugCoordinator: Coordinator {
    func dismissDebugPage(completion: (() -> ())?)
}

class DebugViewController: UIViewController {
    private weak var debugCoordinator: DebugCoordinator?
    private var viewModel: DebugViewModel
    
    @IBOutlet weak var backButton: AppButton!
    @IBOutlet weak var ucviCountLabelIT: UILabel!
    @IBOutlet weak var ucviCountLabelEU: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    init(coordinator: DebugCoordinator, viewModel: DebugViewModel) {
        self.debugCoordinator = coordinator
        self.viewModel = viewModel

        super.init(nibName: "DebugView", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ucviCountLabelIT.text = "download..."
        self.ucviCountLabelEU.text = "download..."
        
        self.setupBackButton()
        self.setupUCVICountLabelIT()
        self.setupUCVICountLabelEU()
        self.setupTableView()
    }
    
    private func setupBackButton() -> Void {
        self.backButton.style = .minimal
        self.backButton.setLeftImage(named: "icon_back")
    }
    
    private func setupUCVICountLabelIT() -> Void {
        
        print(self.viewModel.getUCVICountIT())
        self.ucviCountLabelIT.text = self.viewModel.getUCVICountIT().stringValue
    }
    
    private func setupUCVICountLabelEU() -> Void {
        
        print(self.viewModel.getUCVICountEU())
        self.ucviCountLabelEU.text = self.viewModel.getUCVICountEU().stringValue
    }
    
    private func setupTableView() -> Void {
        self.tableView.delegate     = self
        self.tableView.dataSource   = self
        self.tableView.registerNibCell(ofType: DebugCell.self, with: "DebugCell")
    }
    
    @IBAction func backButtonDidTap(_ sender: Any) {
        self.debugCoordinator?.dismissDebugPage(completion: nil)
    }
}

extension DebugViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getKIDCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: DebugCell = tableView.dequeueReusableCell(withIdentifier: "DebugCell") as? DebugCell else {
            return UITableViewCell()
        }
        
        cell.fillCell(value: self.viewModel.getPublicKeys()[indexPath.row])
        
        return cell
    }
}

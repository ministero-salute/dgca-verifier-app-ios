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
    @IBOutlet weak var ucviCountLabel: UILabel!
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
        
        self.setupBackButton()
        self.setupUCVICountLabel()
        self.setupTableView()
    }
    
    private func setupBackButton() -> Void {
        self.backButton.style = .minimal
        self.backButton.setLeftImage(named: "icon_back")
    }
    
    private func setupUCVICountLabel() -> Void {
        if !self.viewModel.isDRLDownloadCompleted() {
            self.ucviCountLabel.text = "download..."
            return
        }
        
        print(self.viewModel.getUCVICount())
        self.ucviCountLabel.text = self.viewModel.getUCVICount().stringValue
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

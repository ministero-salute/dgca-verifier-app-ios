//
//  HFBackViewController.swift
//  Verifier
//
//  Created by Johnny Bueti on 08/02/22.
//

import UIKit

protocol HeaderFooterDelegate {
	var header: UIView? { get }
	var contentVC: UIViewController? { get }
	var footer: UIView? { get }
}

class HFBackViewController: UIViewController {
	
	@IBOutlet weak var headerView: UIView!
	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var footerView: UIView!
    @IBOutlet weak var containerStackView: UIStackView!
    
	public var delegate: HeaderFooterDelegate?
	
	override func viewDidLoad() {
        super.viewDidLoad()

		if let header = self.delegate?.header {
			self.headerView.embedSubview(subview: header)
		} else {
			self.headerView.isHidden = true
		}
		
		if let contentVC = self.delegate?.contentVC {			
            self.addChild(contentVC)
            self.contentView.embedSubview(subview: contentVC.view)
		}
		
		if let footer = self.delegate?.footer {
			self.footerView.embedSubview(subview: footer)
		} else {
			self.footerView.isHidden = true
            containerStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
		}
    }

}

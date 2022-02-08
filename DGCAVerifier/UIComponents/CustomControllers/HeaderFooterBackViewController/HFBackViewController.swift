//
//  HFBackViewController.swift
//  Verifier
//
//  Created by Johnny Bueti on 08/02/22.
//

import UIKit

protocol HeaderFooterDelegate {
	var header: 	UIView? { get }
	var content: 	UIView? { get }
	var footer: 	UIView? { get }
}

class HFBackViewController: UIViewController {
	
	@IBOutlet weak var headerView: UIView!
	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var footerView: UIView!
	
	public var delegate: HeaderFooterDelegate?
	
	override func viewDidLoad() {
        super.viewDidLoad()

		if let header = self.delegate?.header {
			self.headerView.embedSubview(subview: header)
		} else {
			self.headerView.isHidden = true
		}
		
		if let content = self.delegate?.content {
			self.contentView.embedSubview(subview: content)
		}
		
		if let footer = self.delegate?.footer {
			self.footerView.embedSubview(subview: footer)
		} else {
			self.footerView.isHidden = true
		}
    }

}

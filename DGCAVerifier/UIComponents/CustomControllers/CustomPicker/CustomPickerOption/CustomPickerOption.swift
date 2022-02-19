//
//  CustomPickerOption.swift
//  Verifier
//
//  Created by Johnny Bueti on 17/02/22.
//

import UIKit

class CustomPickerOption: UIView {
	
	private var nibView: UIView!
	private var selected: Bool = false

	@IBOutlet weak var optionContainerView: UIView!
	var _optionContainerViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet var optionContainerViewBottomConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var scanModeTitleLabel: UILabel!
	@IBOutlet weak var scanModeSubtitleLabel: UILabel!
	
	@IBOutlet weak var descriptionView: UIView!
	@IBOutlet weak var descriptionLabel: UILabel!
	
	@IBOutlet weak var radiusImage: UIImageView!
	
	@IBOutlet var descriptionViewTrailingConstraint: NSLayoutConstraint!
	@IBOutlet var descriptionViewTopConstraint: NSLayoutConstraint!
	@IBOutlet var descriptionViewLeadingConstraint: NSLayoutConstraint!
	@IBOutlet var descriptionViewBottomConstraint: NSLayoutConstraint!
	
	private var _descriptionViewConstraints: [NSLayoutConstraint]!
	
	public override init(frame: CGRect) {
		super.init(frame: frame)

		self.nibView = UINib(nibName: "CustomPickerOption", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView
		self.nibView.frame = self.frame
		
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTap))
		self.nibView.addGestureRecognizer(tapRecognizer)

		self.addSubview(self.nibView)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	@objc private func onTap() {
		if self.selected {
			self.hideDescriptionView()
		} else {
			self.showDescriptionView()
		}
		
		self.selected = !self.selected
	}
	
	private func showDescriptionView() {
		self.descriptionView.isHidden = false
		self.optionContainerViewBottomConstraint.priority = UILayoutPriority(500.0)
		descriptionViewConstraints.forEach{ $0.isActive = true }
	}
	
	private func hideDescriptionView() {
		self.descriptionView.isHidden = true
		descriptionViewConstraints.forEach{ $0.isActive = false }
		self.optionContainerViewBottomConstraint.priority = .required
	}
	
	private var descriptionViewConstraints: [NSLayoutConstraint] {
		return [
			self.descriptionViewBottomConstraint,
			self.descriptionViewTopConstraint,
			self.descriptionViewLeadingConstraint,
			self.descriptionViewTrailingConstraint
		]
	}
	
}

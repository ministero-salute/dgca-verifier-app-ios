//
//  CustomPickerOption.swift
//  Verifier
//
//  Created by Johnny Bueti on 17/02/22.
//

import UIKit

struct CustomPickerOptionContent {
	var scanModeName: String
	var scanModeDescription: String
	var scanModeDetails: String
}

class CustomPickerOption: UIView {
	
	private var nibView: UIView!
	private var selected: Bool = false

	@IBOutlet weak var optionContainerView: UIView!
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
		
	@IBOutlet weak var radioButtonOuter: UIView!
	@IBOutlet weak var radioButtonInner: UIView!
	
	public override init(frame: CGRect) {
		super.init(frame: frame)

		self.nibView = UINib(nibName: "CustomPickerOption", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView
		self.nibView.frame = self.frame
		
		self.setupRadioButton()

		self.addSubview(self.nibView)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	public func fill(with content: CustomPickerOptionContent) {
		self.scanModeTitleLabel.text = content.scanModeName
		self.scanModeSubtitleLabel.text = content.scanModeDescription
		self.descriptionLabel.text = content.scanModeDetails
	}
	
	public func didSelect() {
		self.onTap()
	}
	
	public func reset() {
		self.hideDescriptionView()
	}
	
	private func setupRadioButton() {
		self.radioButtonInner.backgroundColor = Palette.blueDark
		
		self.radioButtonOuter.backgroundColor = Palette.white
		self.radioButtonOuter.borderWidth = 1
		self.radioButtonOuter.borderColor = Palette.blueDark
	}
	
	@objc private func onTap() {
		self.showDescriptionView()
	}
	
	private func showDescriptionView() {
		self.descriptionView.isHidden = false
		self.optionContainerViewBottomConstraint.priority = UILayoutPriority(500.0)
		descriptionViewConstraints.forEach{ $0.isActive = true }
	}
	
	private func hideDescriptionView() {
		guard !self.descriptionView.isHidden else { return }
		
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

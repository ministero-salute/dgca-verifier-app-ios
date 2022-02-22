//
//  CustomPickerOption.swift
//  Verifier
//
//  Created by Johnny Bueti on 17/02/22.
//

import UIKit

struct CustomPickerOptionContent {
	var scanMode: ScanMode
	var scanModeName: String
	var scanModeDescription: String
	var scanModeDetails: String
}

class CustomPickerOption: UIView {
	
	private var nibView: UIView!

	@IBOutlet weak var optionContainerView: UIView!
	@IBOutlet var optionContainerViewBottomConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var scanModeTitleLabel: AppLabel!
	@IBOutlet weak var scanModeSubtitleLabel: AppLabel!
	
	@IBOutlet weak var descriptionView: UIView!
	@IBOutlet weak var descriptionLabel: AppLabel!
		
	@IBOutlet weak var borderView: UIView!
	
	@IBOutlet var descriptionViewTrailingConstraint: NSLayoutConstraint!
	@IBOutlet var descriptionViewTopConstraint: NSLayoutConstraint!
	@IBOutlet var descriptionViewLeadingConstraint: NSLayoutConstraint!
	@IBOutlet var descriptionViewBottomConstraint: NSLayoutConstraint!
		
	@IBOutlet weak var radioButtonOuter: UIView!
	@IBOutlet weak var radioButtonInner: UIView!
	
	public var scanMode: ScanMode!
	
	public override init(frame: CGRect) {
		super.init(frame: frame)

		self.nibView = UINib(nibName: "CustomPickerOption", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView
		self.nibView.frame = self.frame
		
		self.nibView.backgroundColor = Palette.gray
		self.optionContainerView.backgroundColor = Palette.gray
		self.descriptionView.backgroundColor = Palette.grayDark
		
		self.setupLabels()
		self.setRadioButtonSelected(selected: false)
		self.borderView.backgroundColor = Palette.blueDark.withAlphaComponent(0.3)
		self.hideDescriptionView()

		self.addSubview(self.nibView)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	private func setupLabels() {
		self.scanModeTitleLabel.bold 		= true
		self.scanModeTitleLabel.size 		= 15
		self.scanModeSubtitleLabel.size 	= 15
		self.descriptionLabel.bold 			= true
	}
	
	private func setRadioButtonSelected(selected: Bool) {
		self.radioButtonInner.backgroundColor = selected ? Palette.blueDark : Palette.gray
		
		self.radioButtonOuter.backgroundColor = Palette.gray
		self.radioButtonOuter.borderWidth = 1
		self.radioButtonOuter.borderColor = Palette.blueDark
	}
	
	public func fill(with content: CustomPickerOptionContent) {
		self.scanMode = content.scanMode
		
		self.scanModeTitleLabel.text = content.scanModeName
		self.scanModeSubtitleLabel.text = content.scanModeDescription
		self.descriptionLabel.text = content.scanModeDetails
		self.descriptionLabel.sizeToFit()
	}
	
	public func didSelect() {
		self.showDescriptionView()
		self.setRadioButtonSelected(selected: true)
	}
	
	public func reset() {
		self.hideDescriptionView()
		self.setRadioButtonSelected(selected: false)
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

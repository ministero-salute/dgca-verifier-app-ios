//
//  CustomPicker.swift
//  Verifier
//
//  Created by Johnny Bueti on 16/02/22.
//

import UIKit

protocol CustomPickerCoordinator {
	func dismissCustomPicker(completion: (() -> Void)?)
}

class CustomPickerController: UIViewController {
	
	private weak var coordinator: Coordinator?
	
	@IBOutlet weak var closeButton: UIButton!
	@IBOutlet weak var titleLabel: AppLabel!
	@IBOutlet weak var titleLabelBold: AppLabel!
	@IBOutlet weak var optionsStackView: UIStackView!
	
	public init(coordinator: Coordinator) {
		super.init(nibName: "CustomPickerController", bundle: nil)
		
		self.coordinator = coordinator
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.setupTitleLabel()
		self.setupStackView()
    }
	
	private func setupTitleLabel() -> Void {
		self.titleLabel.font = Font.getFont(size: 30, style: .regular)
		self.titleLabelBold.font = Font.getFont(size: 30, style: .bold)
	}
	
	private func setupStackView() -> Void {
		let colors = [UIColor.yellow, UIColor.red, UIColor.black, UIColor.green, UIColor.blue, UIColor.brown, UIColor.purple, UIColor.orange]
		
		for _ in 0...4 {
			let pickerOption = CustomPickerOption()
			pickerOption.backgroundColor = colors.randomElement()
			pickerOption.setContentHuggingPriority(.required, for: .vertical)
			pickerOption.setContentCompressionResistancePriority(.required, for: .vertical)
			
			self.optionsStackView.addArrangedSubview(pickerOption)
		}
	}
	
	@objc private func didSelect(gestureRecognizer: UITapGestureRecognizer) {
		
	}

}

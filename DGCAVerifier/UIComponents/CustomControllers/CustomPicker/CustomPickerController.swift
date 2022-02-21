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
	
	private var optionViews: [CustomPickerOption] = []
	private var optionContents: [CustomPickerOptionContent] = []
	
	public init(coordinator: Coordinator) {
		super.init(nibName: "CustomPickerController", bundle: nil)
		
		self.coordinator = coordinator
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.setupPickerOptionContents()
		self.setupTitleLabel()
		self.setupStackView()
    }
	
	private func setupPickerOptionContents() -> Void {
		ScanMode.allCases.forEach{
			self.optionContents.append(.init(
				scanModeName: $0.buttonTitleName,
				scanModeDescription: $0.buttonTitleBoldName,
				scanModeDetails: $0.pickerOptionName
			))
		}
	}
	
	private func setupTitleLabel() -> Void {
		self.titleLabel.font = Font.getFont(size: 30, style: .regular)
		self.titleLabelBold.font = Font.getFont(size: 30, style: .bold)
	}
	
	private func setupStackView() -> Void {
		let colors = [UIColor.yellow, UIColor.red, UIColor.black, UIColor.green, UIColor.blue, UIColor.brown, UIColor.purple, UIColor.orange]
		
		for index in 0...4 {
			let pickerOption = CustomPickerOption()
			pickerOption.backgroundColor = colors.randomElement()
			pickerOption.tag = index
			pickerOption.fill(with: self.optionContents[index])
			
			let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.didSelect(gestureRecognizer:)))
			pickerOption.addGestureRecognizer(tapGR)
			
			self.optionViews.append(pickerOption)
			
			self.optionsStackView.addArrangedSubview(pickerOption)
		}
	}
	
	@objc private func didSelect(gestureRecognizer: UITapGestureRecognizer) -> Void {
		self.optionViews.forEach{ $0.reset() }
		(gestureRecognizer.view as! CustomPickerOption).didSelect()
	}

}

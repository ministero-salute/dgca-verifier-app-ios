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

protocol CustomPickerDelegate {
	func didSetScanMode(scanMode: ScanMode)
}

class CustomPickerController: UIViewController {
	
	private weak var coordinator: Coordinator?
	
	@IBOutlet weak var headerView: UIView!
	
	@IBOutlet weak var closeButton: UIButton!
	@IBOutlet weak var titleLabel: AppLabel!
	@IBOutlet weak var titleLabelBold: AppLabel!
	@IBOutlet weak var optionsStackView: UIStackView!
	
	private var optionViews: [CustomPickerOption] = []
	private var optionContents: [CustomPickerOptionContent] = []
	
	private var customPickerDelegate: CustomPickerDelegate?
	
	public init(coordinator: Coordinator, customPickerDelegate: CustomPickerDelegate?) {
		super.init(nibName: "CustomPickerController", bundle: nil)
		
		self.coordinator = coordinator
		self.customPickerDelegate = customPickerDelegate
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.view.backgroundColor = Palette.gray
		self.headerView.backgroundColor = Palette.gray
		
		self.setupPickerOptionContents()
		self.setupTitleLabel()
		self.setupStackView()
		self.setupInitiallySelectedOption()
    }
	
	private func setupPickerOptionContents() -> Void {
		ScanMode.allCases.forEach{
			self.optionContents.append(.init(
				scanMode: $0,
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
		self.optionContents.forEach{ content in
			let pickerOption = CustomPickerOption()
			pickerOption.delegate = self.customPickerDelegate
			pickerOption.fill(with: content)
			
			let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.didSelect(gestureRecognizer:)))
			pickerOption.addGestureRecognizer(tapGR)
			
			self.optionViews.append(pickerOption)
			
			self.optionsStackView.addArrangedSubview(pickerOption)
		}
	}
	
	private func setupInitiallySelectedOption() -> Void {
		guard let rawScanMode: String = Store.get(key: .scanMode) else { return }
		
		let scanMode = ScanMode.init(rawValue: rawScanMode)
		self.optionViews.filter{ $0.scanMode == scanMode }.first?.didSelect()
	}
	
	@objc private func didSelect(gestureRecognizer: UITapGestureRecognizer) -> Void {
		self.optionViews.forEach{ $0.reset() }
		
		let pickerOption: CustomPickerOption = gestureRecognizer.view as! CustomPickerOption
		pickerOption.didSelect()
		
		guard let scanMode = pickerOption.scanMode else { return }
		Store.set(scanMode.rawValue, for: .scanMode)
		Store.set(true, for: .isScanModeSet)
	}

}

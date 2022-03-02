//
//  CustomPicker.swift
//  Verifier
//
//  Created by Johnny Bueti on 16/02/22.
//

import UIKit

protocol CustomPickerCoordinator: Coordinator {
    func dismissCustomPicker(completion: (() -> Void)?)
}

protocol CustomPickerDelegate {
    func didSetScanMode(scanMode: ScanMode)
}

class CustomPickerController: UIViewController {
    
    private weak var coordinator: CustomPickerCoordinator?
    
    @IBOutlet weak var shadowViewContainer: AppShadowView!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var confirmButton: AppButton!
    @IBOutlet weak var titleLabel: AppLabel!
    @IBOutlet weak var optionsStackView: UIStackView!
    
    private var optionViews: [CustomPickerOption] = []
    private var optionContents: [CustomPickerOptionContent] = []
    private var selectedScanMode: ScanMode?
    
    private var customPickerDelegate: CustomPickerDelegate?
    
    public init(coordinator: CustomPickerCoordinator, customPickerDelegate: CustomPickerDelegate?) {
        super.init(nibName: "CustomPickerController", bundle: nil)
        
        self.coordinator = coordinator
        self.customPickerDelegate = customPickerDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Palette.black.withAlphaComponent(0.65)
        self.shadowViewContainer.backgroundColor = Palette.white
        self.headerView.backgroundColor = Palette.white
        
        self.setupPickerOptionContents()
        self.setupTitleLabel()
        self.setupStackView()
        self.setupConfirmButtonInitialState()
        
        self.optionViews.forEach{ $0.reset() }
        self.setupInitiallySelectedOption()
    }

    private func setupPickerOptionContents() -> Void {
        ScanMode.allCases.forEach{
            self.optionContents.append(.init(
                scanMode: $0,
                scanModeName: $0.buttonTitleName,
                scanModeDescription: $0.buttonTitleBoldName,
                scanModeDetails: $0.associatedPickerDescriptionScanMode
            ))
        }
    }
    
    private func setupTitleLabel() -> Void {
        self.titleLabel.font = Font.getFont(size: 22, style: .regular)
    }
    
    private func setupStackView() -> Void {
        self.optionContents.enumerated().forEach{ (index, content) in
            let pickerOption = CustomPickerOption()
            pickerOption.fill(with: content)
            
            if index == self.optionContents.count - 1 {
                pickerOption.borderView.isHidden = true
            }
            
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
    
    private func setupConfirmButtonInitialState() -> Void {
        Store.get(key: .scanMode) == nil ? disableConfirmButton() : enableConfirmButton()
    }
    
    private func disableConfirmButton(){
        self.confirmButton.style = .disabled
        self.confirmButton.alpha = 0.8
        self.confirmButton.contentHorizontalAlignment = .center
    }

    public func enableConfirmButton() {
        self.confirmButton.style = .blue
        self.confirmButton.alpha = 1
        self.confirmButton.contentHorizontalAlignment = .center
    }
    
    @objc private func didSelect(gestureRecognizer: UITapGestureRecognizer) -> Void {
        self.optionViews.forEach{ $0.reset() }
        
        let pickerOption: CustomPickerOption = gestureRecognizer.view as! CustomPickerOption
        pickerOption.didSelect()
        
        self.selectedScanMode = pickerOption.scanMode
        enableConfirmButton()
    }
    
    @IBAction func didTapConfirm(_ sender: Any) {
        guard let selectedScanMode = self.selectedScanMode else { return }
        
        Store.set(selectedScanMode.rawValue, for: .scanMode)
        Store.set(true, for: .isScanModeSet)
        
        self.coordinator?.dismissCustomPicker(completion: nil)
        self.customPickerDelegate?.didSetScanMode(scanMode: selectedScanMode)
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        self.coordinator?.dismissCustomPicker(completion: nil)
    }

}

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
    
    @IBOutlet weak var scrollView: UIScrollView!
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                        
        let scrollOffset: Double = self.notVisibleOptionScrollOffset()
        if (scrollOffset > 0) {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: scrollOffset), animated: true)
        }
    }

    private func setupPickerOptionContents() -> Void {
        ScanMode.allCases.forEach{
            guard $0 != .work, $0 != .school else { return }
            
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
    
    private func notVisibleOptionScrollOffset() -> Double {
        guard let scanMode: ScanMode = ScanMode.fetchFromLocalSettings() else { return 0.0 }
        guard let selectedOptionIndex: Int = self.optionViews.enumerated().compactMap({ index, optionView in
            optionView.scanMode == scanMode ? index : nil
        }).first else { return 0.0 }
        
        // Select first non-selected option to determine the height of a non-selected option.
        // A selected option spans an additional view containing the scan mode description.
        var baseNotSelectedOptionHeight: Double = 0.0
        for index in 0..<self.optionsStackView.arrangedSubviews.count {
            if index != selectedOptionIndex {
                baseNotSelectedOptionHeight = self.optionsStackView.arrangedSubviews[index].frame.height
                break
            }
        }

        let unselectedOptionsHeight: Double = Double(selectedOptionIndex) * baseNotSelectedOptionHeight
        let selectedOptionHeight: Double = self.optionsStackView.arrangedSubviews[selectedOptionIndex].frame.height
        
        return unselectedOptionsHeight + selectedOptionHeight - self.scrollView.frameLayoutGuide.layoutFrame.size.height
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
        guard let selectedScanMode = self.selectedScanMode else {
            self.coordinator?.dismissCustomPicker(completion: nil)
            return
        }
        
        // If, for some reason, the user managed to get to this point attempting to select the `.work` and `.school` scan mode,
        // exit early.
        guard selectedScanMode != .work, selectedScanMode != .school else { return }
        
        Store.set(selectedScanMode.rawValue, for: .scanMode)
        Store.set(true, for: .isScanModeSet)
        
        self.coordinator?.dismissCustomPicker(completion: nil)
        self.customPickerDelegate?.didSetScanMode(scanMode: selectedScanMode)
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        self.coordinator?.dismissCustomPicker(completion: nil)
    }

}

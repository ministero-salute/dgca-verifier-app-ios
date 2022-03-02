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
    var scanModeDetails: String?
}

class CustomPickerOption: UIView {
    
    private var nibView: UIView!

    @IBOutlet weak var optionContainerView: UIView!
    @IBOutlet var optionContainerViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var scanModeTitleLabel: AppLabel!
    
    @IBOutlet weak var borderView: UIView!
        
    @IBOutlet weak var radioButtonOuter: UIView!
    @IBOutlet weak var radioButtonInner: UIView!
    
    private var pDescriptionView: UIView!
    private var content: CustomPickerOptionContent!
    
    public var scanMode: ScanMode {
        return self.content.scanMode
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.nibView = UINib(nibName: "CustomPickerOption", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView
        self.nibView.translatesAutoresizingMaskIntoConstraints = false
        
        self.nibView.backgroundColor = Palette.white
        self.optionContainerView.backgroundColor = Palette.white
        
        self.setupLabels()
        self.setRadioButtonSelected(selected: false)
        self.borderView.backgroundColor = Palette.blueDark.withAlphaComponent(0.3)

        self.addSubview(self.nibView)
        
        self.nibView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.nibView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.nibView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.nibView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.setContentCompressionResistancePriority(.required, for: .vertical)
        self.nibView.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupLabels() {
        self.scanModeTitleLabel.bold = true
        self.scanModeTitleLabel.size = 15
    }
    
    private func setRadioButtonSelected(selected: Bool) {
        self.radioButtonInner.backgroundColor = selected ? Palette.blueDark : Palette.white
        
        self.radioButtonOuter.backgroundColor = Palette.white
        self.radioButtonOuter.borderWidth = 1
        self.radioButtonOuter.borderColor = Palette.blueDark
    }
    
    public func fill(with content: CustomPickerOptionContent) {
        self.content = content
        self.scanModeTitleLabel.text = content.scanModeName
        
        self.pDescriptionView = self.makeDescriptionView()
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
        self.nibView.addSubview(self.pDescriptionView)

        self.pDescriptionView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        self.pDescriptionView.widthAnchor.constraint(equalTo: self.optionContainerView.widthAnchor, constant: -32.0).isActive = true
        self.pDescriptionView.centerXAnchor.constraint(equalTo: self.nibView.centerXAnchor).isActive = true
        self.pDescriptionView.topAnchor.constraint(equalTo: self.optionContainerView.bottomAnchor).isActive = true
                
        let labelRef: UILabel = self.pDescriptionView.subviews.filter{ $0 is UILabel }.first! as! UILabel
        labelRef.setContentCompressionResistancePriority(.required, for: .vertical)
        
        labelRef.centerYAnchor.constraint(equalTo: self.pDescriptionView.centerYAnchor).isActive = true
        labelRef.centerXAnchor.constraint(equalTo: self.pDescriptionView.centerXAnchor).isActive = true
        labelRef.widthAnchor.constraint(equalTo: self.pDescriptionView.widthAnchor, constant: -32.0).isActive = true
        
        self.pDescriptionView.heightAnchor.constraint(greaterThanOrEqualTo: labelRef.heightAnchor, constant: 32.0).isActive = true
        self.borderView.topAnchor.constraint(equalTo: self.pDescriptionView.bottomAnchor, constant: 16.0).isActive = true
        
        self.pDescriptionView.needsUpdateConstraints()
    }
    
    private func hideDescriptionView() {
        self.optionContainerViewBottomConstraint.priority = UILayoutPriority(999.0)
        self.pDescriptionView.removeFromSuperview()
    }
    
    private func makeDescriptionView() -> UIView {
        let descriptionView: UIView = UIView()
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        descriptionView.backgroundColor = Palette.scanModeGray
        
        let descriptionLabel: AppLabel = {
            let label = AppLabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.bold = true
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 0
            label.text = self.content.scanModeDetails
            return label
        }()
        
        descriptionView.addSubview(descriptionLabel)
        
        return descriptionView
    }
    
}

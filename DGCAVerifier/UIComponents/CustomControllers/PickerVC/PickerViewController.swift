/*
 *  license-start
 *
 *  Copyright (C) 2021 Ministero della Salute and all other contributors
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
*/

//
//  PickerView.swift
//  VerificaC19
//
//  Created by Johnny Bueti on 18/10/21.
//

import Foundation
import UIKit
import SwiftDGC

class PickerViewController: UIViewController {
    
    @IBOutlet weak var pickerView:          UIStackView!
    @IBOutlet weak var backgroundView:      UIView!
    @IBOutlet weak var pickerViewComponent: UIPickerView!
    @IBOutlet weak var pickerViewHeader:    UIView!
    @IBOutlet weak var pickerViewTitle:     UILabel!
    @IBOutlet weak var itemDone:            UIBarButtonItem!
    @IBOutlet weak var itemCancel:          UIBarButtonItem!
    
    private lazy var content: PickerContent = .init(doneButtonTitle: "label.done".localized, cancelButtonTitle: "label.cancel".localized, pickerOptions: [])
    
    /// Determines whether the tap on the background view dismisses the `PickerView` or not.
    private var isTapToDismissEnabled: Bool = true
    
    public struct PickerContent {
        var headerTitle:        String?
        var doneButtonTitle:    String = "label.done".localized
        var cancelButtonTitle:  String? = "label.cancel".localized
        var pickerOptions:      [String]
        var selectedOption:     Int = 0
        var doneCallback:       ((PickerViewController) -> ())? = nil
        var cancelCallback:     (() -> ())? = nil
        
        /// Determines whether the user should be able to tap anywhere outside the `PickerView` area to dismiss the `PickerView`.
        var tapAnywhereToDismissEnabled: Bool = true
    }
    
    public static func present(for sender: UIViewController, with content: PickerContent) {
        let vc                      = PickerViewController(content: content)
        vc.modalPresentationStyle   = .overFullScreen
        sender.present(vc, animated: false, completion: nil)
    }
    
    init(content: PickerContent) {
        super.init(nibName: "PickerViewController", bundle: nil)
        self.content = content
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.fillView(with: self.content)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        backgroundView.addGestureRecognizer(tap)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animatePresentingPicker()
    }
    
    private func fillView(with content: PickerContent) {
        self.initialize()
    }
    
    private func initialize() {
        self.pickerViewComponent.showsSelectionIndicator    = true
        self.pickerViewComponent.delegate                   = self
        self.pickerViewComponent.dataSource                 = self
        
        if self.content.headerTitle == nil {
            self.pickerViewHeader.isHidden = true
        }
        
        self.pickerViewTitle.text                           = self.content.headerTitle
        
        self.itemDone.title                                 = content.doneButtonTitle
        self.itemCancel.title                               = content.cancelButtonTitle
        
        self.itemDone.action                                = #selector(self.didTapDone)
        self.itemCancel.action                              = #selector(self.didTapCancel)
        
        self.isTapToDismissEnabled                          = content.tapAnywhereToDismissEnabled
        
        self.backgroundView.backgroundColor                 = backgroundColor
        self.view.backgroundColor                           = .clear
        
        self.selectRow(self.content.selectedOption, animated: false)
    }
    
    public func selectRow(_ row: Int, animated: Bool) {
        self.pickerViewComponent.selectRow(row, inComponent: 0, animated: animated)
    }
    
    public func selectedRow() -> Int {
        return self.pickerViewComponent.selectedRow(inComponent: 0)
    }
    
    /// Sets the default "tap anywhere outside the active picker area to dismiss" behaviour, enabling or disabling it. This behaviour is **enabled by default**.
    /// - Parameter disabled: whether the behaviour should be **disabled** or not. Setting this to `true` makes it possible for the user to dismiss the `PickerView` exclusively by either tapping "Cancel" or "Done".
    public func shouldDisableTapToDismiss(disabled: Bool) -> Void {
        self.isTapToDismissEnabled = false
    }

    @objc private func didTapDone() {
        self.dismissPicker(completionHandler: nil)
        self.content.doneCallback?(self)
    }
    
    @objc private func didTapCancel() {
        self.dismissPicker(completionHandler: nil)
        self.content.cancelCallback?()
    }
    
    @objc private func didTapBackground() {
        if !self.isTapToDismissEnabled {
            return
        }
        
        self.didTapCancel()
    }
}

extension PickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerItemLabel() -> UILabel {
        let font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        let itemLabel = UILabel()
        itemLabel.font = font
        itemLabel.adjustsFontForContentSizeCategory = true
        itemLabel.textAlignment = .center
        itemLabel.numberOfLines = 0
        return itemLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var optionLabel: UILabel? = (view as? UILabel)
        if optionLabel == nil {
            optionLabel = pickerItemLabel()
        }
        
        let text = self.content.pickerOptions[row]
        optionLabel!.text = text
        return optionLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        if component == 0 {
            let longestTextLenght = self.content.pickerOptions.map{ $0.count }.max()
            if let longestText = self.content.pickerOptions.first(where: { $0.count == longestTextLenght }) {
                let font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
                let horizontalPadding: CGFloat = 64
                let verticalPadding: CGFloat = 4
                let height = longestText.height(withConstrainedWidth: pickerView.bounds.width - horizontalPadding, font: font) + verticalPadding
                return height
            }
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return self.content.pickerOptions.count
        } else {
            return 0
        }
    }
}

extension PickerViewController {
    private func animatePresentingPicker() {
        self.pickerView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
        self.pickerViewHeader.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
        
        UIView.animate (
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.2,
            options: .curveEaseOut,
            animations: { [weak self] in
                self?.pickerView.transform = .identity
                self?.pickerViewHeader.transform = .identity
            }
        )
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in self?.backgroundView.alpha = 1.0 })
    }
        
    private func dismissPicker(completionHandler: (()->())? = nil) {
        animateDismission()
        dismissAnimationCompletion(completionHandler)
    }
    
    private func animateDismission() {
        UIView.animate (
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.2,
            options: .curveEaseOut,
            animations: { [weak self] in self?.dismissAnimation() }
        )
    }
    
    private func dismissAnimation() {
        self.pickerView.frame = CGRect(
            x: 0,
            y: self.view.frame.height,
            width: self.view.frame.width,
            height: self.pickerView.frame.height
        )
        
        self.pickerViewHeader.frame = CGRect(
            x: 0,
            y: self.view.frame.height,
            width: self.view.frame.width,
            height: self.pickerViewHeader.frame.height
        )
    }
    
    private func dismissAnimationCompletion(_ completionHandler: (()->())? = nil) {
        UIView.animate (
            withDuration: 0.2,
            animations: { [weak self] in self?.backgroundView.alpha = 0.0 },
            completion: { [weak self] _ in self?.dismiss(completionHandler) }
        )
    }

    private func dismiss(_ completion: (()->())? = nil) {
        self.dismiss(animated: false, completion: completion)
    }

    private var backgroundColor: UIColor {
        Palette.black.withAlphaComponent(0.7)
    }
}

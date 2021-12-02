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
//  AppAlertViewController.swift
//  Verifier
//
//  Created by Andrea Prosseda on 07/09/21.
//

import UIKit
public class AppAlertViewController: UIViewController {
    
    public static func present(for sender: UIViewController, with content: AlertContent) {
        let vc = AppAlertViewController(content: content)
        vc.modalPresentationStyle = .overFullScreen
        sender.present(vc, animated: false, completion: nil)
    }
    
    init(content: AlertContent) {
        super.init(nibName: "AppAlertViewController", bundle: nil)
        self.content = content
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet private weak var alertView: UIView!
    @IBOutlet private weak var titleLabel: AppLabel!
    @IBOutlet private weak var messageLabel: AppLabel!
    @IBOutlet private weak var confirmButton: AppButton!
    @IBOutlet private weak var cancelButton: AppLabelUrl!

    private lazy var content: AlertContent = .init()

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animatePresentingAlert()
    }
    
    override public func viewDidLoad() {
        alertView.cornerRadius = 4
        setTitle()
        setMessage()
        setCancelButton()
        setConfirmButton()
    }

    private func setTitle() {
        titleLabel.text = content.title
        titleLabel.isHidden = content.title == nil
    }
    
    private func setMessage() {
        messageLabel.text = content.message
        messageLabel.isHidden = content.message == nil
    }
    
    private func setCancelButton() {
        let title = content.cancelActionTitle ?? ""
        let tap = UITapGestureRecognizer(target: self, action: #selector(cancelDidTap))
        cancelButton.fillView(with: .init(text: title, onTap: tap))
        cancelButton.isHidden = content.cancelActionTitle == nil
    }
    
    private func setConfirmButton() {
        confirmButton.setTitle(content.confirmActionTitle)
        confirmButton.isHidden = content.confirmActionTitle == nil
    }

    @IBAction func confirmDidTap() {
//        dismissAlert()
//        content.confirmAction?()
        dismissAlert { [weak self] in
            guard let `self` = self else { return }
            self.content.confirmAction?()
        }
    }
    
    @objc func cancelDidTap() {
//        dismissAlert()
//        content.cancelAction?()
        dismissAlert { [weak self] in
            guard let `self` = self else { return }
            self.content.cancelAction?()
        }
    }
}

// Animations
extension AppAlertViewController {
    
    private func animatePresentingAlert() {
        animate(willAppear: false)
        
        UIView.animate (
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.2,
            options: .curveEaseIn,
            animations: { [weak self] in self?.animate(willAppear: true) })
    }
    
    private func dismissAlert(completionHandler: (()->())? = nil) {
        UIView.animate (
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.2,
            options: .curveEaseIn,
            animations: { [weak self] in self?.animate(willAppear: false) }
        ) { [weak self] _ in self?.dismiss(animated: false, completion: completionHandler) }
    }
    
    private func animate(willAppear: Bool) {
        alertView.alpha = willAppear ? 1 : 0
        alertView.backgroundColor = willAppear ? getDefaultAlertColor() : .clear
        alertView.transform = willAppear ? .identity : .init(scaleX: 0.85, y: 0.85)
        
        let alpha: CGFloat = willAppear ? 0.8 : 0
        view.backgroundColor = getDefaultBackgroundColor(with: alpha)
    }
    
    private func getDefaultAlertColor() -> UIColor {
        return .white
    }
    
    private func getDefaultBackgroundColor(with alpha: CGFloat) -> UIColor {
        return Palette.blue.withAlphaComponent(alpha)
    }
    
}

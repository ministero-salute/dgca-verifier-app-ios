//
//  UIButton+Set.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 26/07/21.
//

import UIKit

extension UIButton {
    
    var allStates: [UIControl.State] {
        return [.application, .disabled, .focused, .highlighted, .normal, .reserved, .selected]
    }
    
    func setImage(_ image: UIImage?) {
        allStates.forEach { self.setImage(image, for: $0) }
    }
    
    func setTitle(_ title: String?, uppercased: Bool = true) {
        UIView.performWithoutAnimation { [weak self] in
            let title = uppercased ? title?.localized.uppercased() : title?.localized
            self?.allStates.forEach { self?.setTitle(title, for: $0) }
            layoutIfNeeded()
        }
    }

}

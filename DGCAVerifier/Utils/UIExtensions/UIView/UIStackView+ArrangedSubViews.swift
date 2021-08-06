//
//  UIStackView+ArrangedSubViews.swift
//  Verifier
//
//  Created by Andrea Prosseda on 27/07/21.
//

import UIKit

public extension UIStackView {
    
    func removeAllArrangedSubViews() {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}


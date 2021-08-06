//
//  UIView+Borders.swift
//  Verifier
//
//  Created by Andrea Prosseda on 26/07/21.
//

import UIKit

extension UIView {
        
    func setBorder(color: UIColor = Palette.blue, width: CGFloat = 1, cornerRadius: CGFloat = 4) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        layer.cornerRadius = cornerRadius
    }
    
    func removeBorder() {
        layer.borderColor = UIColor.white.withAlphaComponent(0).cgColor
        layer.borderWidth = 0
    }
}

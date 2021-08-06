//
//  CALayer+Shadow.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 26/07/21.
//

import UIKit

public extension CALayer {
    
    func animateShadowOpacity(to value: Float) {
        let animation = CABasicAnimation(keyPath: "shadowOpacity")
        animation.fromValue = shadowOpacity
        animation.toValue = value
        animation.duration = 0.5
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards;
        add(animation, forKey: animation.keyPath)
        shadowOpacity = value
    }
    
    func addShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0)
    {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}

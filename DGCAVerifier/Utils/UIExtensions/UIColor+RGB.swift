//
//  UIColor+RGB.swift
//  Verifier
//
//  Created by Andrea Prosseda on 26/07/21.
//

import UIKit

extension UIColor {
    
    convenience public init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
}

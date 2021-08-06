//
//  UILabel+Inspectable.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 26/07/21.
//

import UIKit

extension UILabel {
    
    @IBInspectable
    var localizedText: String? {
        get { return self.text }
        set { self.text = newValue?.localized }
    }
    
}

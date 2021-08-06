//
//  UIButton+Inspectable.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 26/07/21.
//

import UIKit

extension UIButton {
    
    @IBInspectable
    var localizedText: String? {
        get { return self.title(for: .normal) }
        set { setTitle(newValue) }
    }
    
}

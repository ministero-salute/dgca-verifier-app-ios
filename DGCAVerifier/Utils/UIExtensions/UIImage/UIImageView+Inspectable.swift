//
//  UIImage.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 26/07/21.
//

import UIKit

extension UIImageView {
    
    @IBInspectable
    var named: String {
        get { return "" }
        set { self.image = UIImage(named: newValue) }
    }
    
}

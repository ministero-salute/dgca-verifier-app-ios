//
//  UIView+NibFile.swift
//  Verifier
//
//  Created by Emilio Apuzzo on 19/10/21.
//

import UIKit

public extension UIView {
    
    class func instanceFromNib(nibName: String) -> UIView {
        return UINib(nibName: nibName, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}

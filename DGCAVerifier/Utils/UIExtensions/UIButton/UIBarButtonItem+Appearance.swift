//
//  UIBarButtonItem+Appearance.swift
//  Verifier
//
//  Created by Andrea Prosseda on 26/07/21.
//

import UIKit

extension UIBarButtonItem {
    
    var allStates: [UIControl.State] {
        return [.application, .disabled, .focused, .highlighted, .normal, .reserved, .selected]
    }
    
    func setTitleAppearance() {
        let keys: [NSAttributedString.Key: Any] = [.foregroundColor: Palette.blue, .font: Font.getFont(size: 12, style: .bold)]
        allStates.forEach{ setTitleTextAttributes(keys, for: $0) }
    }
    
}

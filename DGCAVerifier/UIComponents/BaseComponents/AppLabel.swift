//
//  AppLabel.swift
//  Verifier
//
//  Created by Andrea Prosseda on 26/07/21.
//

import UIKit

class AppLabel: UILabel {
        
    @IBInspectable var bold: Bool = false       { didSet { initialize() } }
    @IBInspectable var size: CGFloat = 12       { didSet { initialize() } }
    @IBInspectable var uppercased: Bool = false { didSet { initialize() } }
    
    override var text: String? { didSet { toUppercase() } }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        font = Font.getFont(size: size, style: bold ? .bold : .regular)
        textColor = Palette.blueDark
        toUppercase()
    }

    func toUppercase() {
        guard uppercased else { return }
        guard (text?.uppercased() ?? "") != (text ?? "") else { return }
        text = text?.uppercased()
    }
}


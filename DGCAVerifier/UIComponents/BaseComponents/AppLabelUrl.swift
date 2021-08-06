//
//  AppLabelUrl.swift
//  Verifier
//
//  Created by Andrea Prosseda on 26/07/21.
//

import UIKit

class AppLabelUrl: AppLabel {
    
    public struct Content {
        public var text: String
        public var onTap: UITapGestureRecognizer?
        
        public init(text: String, onTap: UITapGestureRecognizer? = nil) {
            self.text = text
            self.onTap = onTap
        }
        
    }
    
    public func fillView(with content: Content) {
        initialize()
        text = content.text.localized
        if let tap = content.onTap {
            self.addGestureRecognizer(tap)
        }
    }
    
    override func initialize() {
        super.initialize()
        font = Font.getFont(size: size, style: .semiBold)
        isUserInteractionEnabled = true
        underlineText()
    }

    private func underlineText() {
        let underlineAttributedString = NSAttributedString(
            string: text ?? "",
            attributes: [.underlineStyle: NSUnderlineStyle.thick.rawValue]
        )
        self.attributedText = underlineAttributedString
    }
    
}


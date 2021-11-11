/*
 *  license-start
 *  
 *  Copyright (C) 2021 Ministero della Salute and all other contributors
 *  
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  
 *      http://www.apache.org/licenses/LICENSE-2.0
 *  
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
*/

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
        add(content.onTap)
    }
    
    public func add(_ tap: UITapGestureRecognizer?) {
        guard let tap = tap else { return }
        self.addGestureRecognizer(tap)
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


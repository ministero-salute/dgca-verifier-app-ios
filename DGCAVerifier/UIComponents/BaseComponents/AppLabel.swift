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
    @IBInspectable var containsLinks: Bool = false
    
    override var text: String? { didSet { toUppercase() } }
    override var attributedText: NSAttributedString? { didSet { toUppercase() } }
    
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
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        guard let attributedText = self.attributedText, self.containsLinks else {
            return super.point(inside: point, with: event)
        }
                
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        
       
        let textStorage = NSTextStorage(attributedString: attributedText)
        textStorage.addAttribute(NSAttributedString.Key.font, value: font!, range: NSMakeRange(0, attributedText.length))
        textStorage.addLayoutManager(layoutManager)
        
        let locationOfTouchInLabel = point
        
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        var alignmentOffset: CGFloat!
        switch textAlignment {
        case .left, .natural, .justified:
            alignmentOffset = 0.0
        case .center:
            alignmentOffset = 0.5
        case .right:
            alignmentOffset = 1.0
        @unknown default:
            fatalError()
        }
        
        let xOffset = ((bounds.size.width - textBoundingBox.size.width) * alignmentOffset) - textBoundingBox.origin.x
        let yOffset = ((bounds.size.height - textBoundingBox.size.height) * alignmentOffset) - textBoundingBox.origin.y
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - xOffset, y: locationOfTouchInLabel.y - yOffset)
        
        let characterIndex = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        let attributeName = NSAttributedString.Key.link
        
        let attributeValue = self.attributedText?.attribute(attributeName, at: characterIndex, effectiveRange: nil)
        
        if let value = attributeValue {
            if let url = value as? URL {
                UIApplication.shared.open(url)
            }
        }
        
        return super.point(inside: point, with: event)
        
    }
    
}

//
//  ExtendedUIButton.swift
//  Verifier
//
//  Created by Johnny Bueti on 18/02/22.
//

import Foundation
import UIKit

/// Identifies a `UIButton` whose *tappable area* can be extended.
@IBDesignable
class ExtendedUIButton: UIButton {
    
    @IBInspectable
    public var extendedTappableMargin: CGFloat = 5.0
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return self.bounds.insetBy(dx: -self.extendedTappableMargin, dy: -self.extendedTappableMargin).contains(point)
    }
    
}

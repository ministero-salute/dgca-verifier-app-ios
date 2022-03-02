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

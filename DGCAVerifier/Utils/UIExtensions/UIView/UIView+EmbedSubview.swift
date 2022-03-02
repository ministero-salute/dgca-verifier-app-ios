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
//  UIView+EmbedSubview.swift
//  Verifier
//
//  Created by Johnny Bueti on 08/02/22.
//

import Foundation
import UIKit

extension UIView {
    public func embedSubview(subview: UIView) {
        let constraints = self.getAnchorConstraintsRelativeTo(view: subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(subview)
        NSLayoutConstraint.activate(constraints)
    }
}

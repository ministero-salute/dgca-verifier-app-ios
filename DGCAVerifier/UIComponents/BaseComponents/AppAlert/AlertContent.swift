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
//  AlertContent.swift
//  Verifier
//
//  Created by Andrea Prosseda on 07/09/21.
//

import Foundation
import UIKit

public struct AlertContent {

    public typealias Action = () -> ()

    public var title: String?
    public var message: String?
    public var confirmAction: Action?
    public var confirmActionTitle: String?
    public var cancelAction: Action?
    public var cancelActionTitle: String?
    public var isHTMLBased: Bool = false

    
    public init (
        title: String? = nil,
        message: String? = nil,
        confirmAction: Action? = nil,
        confirmActionTitle: String? = nil,
        cancelAction: Action? = nil,
        cancelActionTitle: String? = nil,
        isHTMLBased: Bool = false
    ) {
        self.title = title?.localized
        self.message = message?.localized
        self.confirmAction = confirmAction
        self.confirmActionTitle = confirmActionTitle?.localized
        self.cancelAction = cancelAction
        self.cancelActionTitle = cancelActionTitle?.localized
        self.isHTMLBased = isHTMLBased
    }
}

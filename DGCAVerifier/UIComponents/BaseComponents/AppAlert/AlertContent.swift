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
    
    public init (
        title: String? = nil,
        message: String? = nil,
        confirmAction: Action? = nil,
        confirmActionTitle: String? = nil,
        cancelAction: Action? = nil,
        cancelActionTitle: String? = nil
    ) {
        self.title = title?.localized
        self.message = message?.localized
        self.confirmAction = confirmAction
        self.confirmActionTitle = confirmActionTitle?.localized
        self.cancelAction = cancelAction
        self.cancelActionTitle = cancelActionTitle?.localized
    }
}

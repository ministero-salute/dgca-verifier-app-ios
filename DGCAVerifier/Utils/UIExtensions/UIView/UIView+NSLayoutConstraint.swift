//
//  UIView+NSLayoutConstraint.swift
//  Verifier
//
//  Created by Johnny Bueti on 08/02/22.
//

import Foundation
import UIKit

extension UIView {
    public func getAnchorConstraintsRelativeTo(view: UIView) -> [NSLayoutConstraint] {
        return [
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
    }
}

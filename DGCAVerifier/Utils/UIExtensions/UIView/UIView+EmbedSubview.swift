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

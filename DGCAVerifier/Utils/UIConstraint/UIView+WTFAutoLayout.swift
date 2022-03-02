//
//  UIConstraint+WTFAutoLayout.swift
//  VerificaC19
//
//  Created by Johnny Bueti on 02/03/22.
//

import Foundation
import UIKit

extension UIView {
    public func generateWTFAutoLayoutReadableConstraints() -> String {
        return self.constraints.enumerated().reduce("(\n", { previousString, enumeratedConstraint in
            previousString + "\"\(enumeratedConstraint.element)\"\(enumeratedConstraint.offset == self.constraints.count - 1 ? "" : ",")\n"
        }) + ")\n"
    }
}

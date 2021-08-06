//
//  AppShadowView.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 26/07/21.
//

import UIKit

class AppShadowView: UIView {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    public func initialize() {
        cornerRadius = 4
        hideShadow()
        addShadow()
    }
    
}


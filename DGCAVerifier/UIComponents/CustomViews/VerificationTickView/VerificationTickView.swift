//
//  VerificationTickView.swift
//  Verifier
//
//  Created by Emilio Apuzzo on 25/02/22.
//

import Foundation
import UIKit

class VerificationTickView: AppView{
    
    @IBOutlet weak var tickImageView: UIImageView!
    @IBOutlet weak var tickLabel: AppLabel!
    
    public override init() {
        super.init()
        tickLabel.bold = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

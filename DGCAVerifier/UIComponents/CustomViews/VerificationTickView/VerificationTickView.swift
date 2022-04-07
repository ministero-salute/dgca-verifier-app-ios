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

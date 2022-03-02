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
//  ButtonBar.swift
//  Verifier
//
//  Created by Johnny Bueti on 09/02/22.
//

import UIKit

class FooterBar: AppView {

    @IBOutlet weak var closeView: UIView!
    @IBOutlet weak var viewLabel: AppLabel!
    @IBOutlet weak var viewImage: UIImageView!
    
    private var onTapCallback: (() -> Void)?
    
    public override init() {
        super.init()
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(invokeCallback))
//        closeView.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupTapCallback(callback: @escaping () -> Void) {
        self.onTapCallback = callback
    }
    
    @objc private func invokeCallback() {
        if let cb = self.onTapCallback {
            cb()
        }
    }
    
}

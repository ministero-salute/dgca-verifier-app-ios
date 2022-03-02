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
//  HFBackViewController.swift
//  Verifier
//
//  Created by Johnny Bueti on 08/02/22.
//

import UIKit

protocol HeaderFooterDelegate {
    var header: UIView? { get }
    var contentVC: UIViewController? { get }
    var footer: UIView? { get }
}

class HFBackViewController: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var containerStackView: UIStackView!
    
    public var delegate: HeaderFooterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let header = self.delegate?.header {
            self.headerView.embedSubview(subview: header)
        } else {
            self.headerView.isHidden = true
        }
        
        if let contentVC = self.delegate?.contentVC {            
            self.addChild(contentVC)
            self.contentView.embedSubview(subview: contentVC.view)
        }
        
        if let footer = self.delegate?.footer {
            self.footerView.embedSubview(subview: footer)
        } else {
            self.footerView.isHidden = true
            containerStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        }
    }

}

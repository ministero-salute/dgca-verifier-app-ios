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
//  SettingsCell.swift
//  Verifier
//
//  Created by Emilio Apuzzo on 19/10/21.
//

import UIKit

class SettingsCell: UITableViewCell {

    @IBOutlet weak var containerView: AppShadowView!
    @IBOutlet weak var titleLabel: AppLabel!
    @IBOutlet weak var valueLabel: AppLabel!
    @IBOutlet weak var iconView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        valueLabel.isHidden = true
        iconView.isHidden = true
        self.selectionStyle = .none
        setup()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setup(){
        titleLabel.uppercased = true
        titleLabel.bold = true
    }
    
    func fillCell(title: String, icon: String?, value: String?){
        titleLabel.text = title
        if let value = value {
            valueLabel.isHidden = false
            valueLabel.text = value
        }
        if let icon = icon {
            iconView.image = UIImage(named: icon)
            iconView.isHidden = false
        }
    }

}

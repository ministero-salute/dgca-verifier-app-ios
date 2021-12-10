//
//  DebugCell.swift
//  VerificaC19
//
//  Created by Johnny Bueti on 07/12/21.
//

import UIKit

class DebugCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    
    func fillCell(value: String) {
        self.contentLabel.text = value
    }
    
}

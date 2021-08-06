//
//  CountryCell.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 27/07/21.
//

import UIKit

class CountryCell: UITableViewCell {

    @IBOutlet weak var titleLabel: AppLabel!
    
    func fillCell(with country: String) {
        backgroundColor = .clear
        titleLabel.text = country
    }
    
}

//
//  UITableView+Nib.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 27/07/21.
//

import UIKit

extension UITableView {
    
    func registerNibCell(ofType type: UITableViewCell.Type, with reuseIdentifier: String? = nil) {
        let bundle = Bundle(for: type.self)
        let nib = UINib(nibName: String(describing: type.self), bundle: bundle)
        let identifier = reuseIdentifier != nil ? reuseIdentifier! : String(describing: type.self)
        self.register(nib, forCellReuseIdentifier: identifier)
    }
    
}

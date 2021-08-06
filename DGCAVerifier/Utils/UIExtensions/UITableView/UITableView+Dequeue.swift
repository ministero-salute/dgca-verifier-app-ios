//
//  UITableView+Dequeue.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 27/07/21.
//

import UIKit

public extension UITableView {
    
    func dequeueReusableCell<T: UITableViewCell>(ofType: T.Type, for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as! T
    }
    
}

//
//  String+Char.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 27/07/21.
//

import Foundation

extension String {
 
    subscript(i: Int) -> String { String(self[index(startIndex, offsetBy: i)]) }
    
}

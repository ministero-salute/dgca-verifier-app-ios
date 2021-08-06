//
//  Array+Utils.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 27/07/21.
//

import Foundation

public extension Array {
    
    func get(_ index: Int) -> Element? {
        guard index >= 0 else { return nil }
        guard self.count > index else { return nil }
        return self[index]
    }
    
}

extension Sequence where Element: Hashable {
    
    func distinct() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
    
}

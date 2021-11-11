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
    
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }

}

extension Sequence where Element: Hashable {
    
    func distinct() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
    
}

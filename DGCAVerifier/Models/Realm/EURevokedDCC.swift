//
//  EURevokedDCC.swift
//  Verifier
//
//  Created by Emilio Apuzzo on 20/04/22.
//

import Foundation
import RealmSwift

class EURevokedDCC: Object {
    @Persisted var hashedUVCI: String = ""
    
    convenience init(hash: String) {
        self.init()
        hashedUVCI = hash
    }
    
    override class func primaryKey() -> String? {
        return "hashedUVCI"
    }
}

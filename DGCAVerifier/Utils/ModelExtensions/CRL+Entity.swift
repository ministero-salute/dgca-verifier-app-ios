//
//  CRL+Entity.swift
//  Verifier
//
//  Created by Andrea Prosseda on 25/08/21.
//

import Foundation

extension CRL {
    
    var isSnapshot: Bool {
        guard let revokedUcvi = revokedUcvi else { return false }
        return !revokedUcvi.isEmpty
    }
    
    var isDelta: Bool {
        guard let delta = delta else { return false }
        let inseritons = delta.insertions ?? []
        let deletions = delta.deletions ?? []
        return !inseritons.isEmpty || !deletions.isEmpty
    }
    
}

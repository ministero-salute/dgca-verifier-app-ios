//
//  StatementValidityCheck.swift
//  Verifier
//
//  Created by Davide Aliti on 28/10/21.
//

import Foundation

import SwiftDGC

struct StatementValidityCheck {
    
    private let blacklist = "black_list_uvci"

    func isStatementBlacklisted(_ hCert: HCert) -> Bool {
        guard let blacklist = getBlacklist() else { return false }
        return blacklist.split(separator: ";").contains("\(hCert.uvci)")
        
    }

    private func getBlacklist() -> String? {
        return getValue(for: blacklist)
    }

    private func getValue(for name: String) -> String? {
        return LocalData.getSetting(from: name)
    }
}


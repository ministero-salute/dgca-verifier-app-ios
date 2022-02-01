//
//  BlackListValidator.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 01/02/22.
//

import Foundation
import SwiftDGC

struct BlackListValidator: DGCValidator {
    
    private let blacklist = "black_list_uvci"

    func validate(hcert: HCert) -> Status {
        guard let blacklist = getBlacklist() else { return .valid }
        return blacklist.split(separator: ";").contains("\(hcert.getUVCI())") ? .notValid : .valid
    }
    
    private func getBlacklist() -> String? {
        return getValue(for: blacklist)
    }

    private func getValue(for name: String) -> String? {
        return LocalData.getSetting(from: name)
    }
    
}

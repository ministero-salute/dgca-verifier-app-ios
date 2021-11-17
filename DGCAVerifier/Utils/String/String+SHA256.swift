//
//  String+SHA256.swift
//  Verifier
//
//  Created by Davide Aliti on 20/08/21.
//

import Foundation

extension String {
    func sha256() -> String{
        if let stringData = self.data(using: String.Encoding.utf8) {
            return stringData.sha256()
        }
        return ""
    }
}

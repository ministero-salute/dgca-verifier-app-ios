//
//  MockedCertificates.swift
//  Verifier
//
//  Created by Emilio Apuzzo on 24/03/22.
//

import Foundation

class MockedCertificate: Codable {
    let id: String
    let urlDP: String
    let type, expiringDate, publicKey: String
    let flagEnable: Bool
    let weigthRr: Int
    let kid, publicKeyCertificate: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case urlDP = "url_dp"
        case type
        case expiringDate = "expiring_date"
        case publicKey = "public_key"
        case flagEnable = "flag_enable"
        case weigthRr = "weigth_rr"
        case kid
        case publicKeyCertificate = "public_key_certificate"
    }

    init(id: String, urlDP: String, type: String, expiringDate: String, publicKey: String, flagEnable: Bool, weigthRr: Int, kid: String, publicKeyCertificate: String) {
        self.id = id
        self.urlDP = urlDP
        self.type = type
        self.expiringDate = expiringDate
        self.publicKey = publicKey
        self.flagEnable = flagEnable
        self.weigthRr = weigthRr
        self.kid = kid
        self.publicKeyCertificate = publicKeyCertificate
    }
}

//
//  VaccineExemptionEntry.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 10/01/22.
//

import Foundation
import SwiftDGC
import SwiftyJSON


struct VaccineExemptionEntry : HCertEntry {
    
    var info: [InfoSection] {
        return []
    }
    
    var typeAddon: String {
        return ""
    }
    
    var validityFailures: [String] {
        return []
    }
    
    let diseaseTargeted: String
    let issuer: String
    let countryCode: String
    let uvci: String
    let dateFrom: Date?
    let dateUntil: Date?
    
    
    enum Fields: String {
        case diseaseTargeted = "tg"
        case countryCode = "co"
        case issuer = "is"
        case uvci = "ci"
        case dateFrom = "df"
        case dateUntil = "du"
    }
    
    init?(body: JSON) {
        //        "e" : [
        //          {
        //            "co" : "IT",
        //            "du" : "2021-12-15",
        //            "df" : "2021-12-15",
        //            "tg" : "840539006",
        //            "is" : "IT",
        //            "ci" : "01ITF4BCB7E4FFD14913B39FF3CB3C70C694#3"
        //          }
        //        ],
        guard
            let diseaseTargeted = body[Fields.diseaseTargeted.rawValue].string,
            let country = body[Fields.countryCode.rawValue].string,
            let issuer = body[Fields.issuer.rawValue].string,
            let uvci = body[Fields.uvci.rawValue].string,
            let df = body[Fields.dateFrom.rawValue].string
        else {
            return nil
        }
        self.diseaseTargeted = diseaseTargeted
        self.countryCode = country
        self.issuer = issuer
        self.uvci = uvci
        self.dateFrom = Date(dateString: df)
        let du = body[Fields.dateUntil.rawValue].string
        self.dateUntil = du != nil ? Date(dateString: du!) : nil
    }
    
}

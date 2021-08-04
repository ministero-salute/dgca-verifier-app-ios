//
//  Link+Values.swift
//  Verifier
//
//  Created by Andrea Prosseda on 28/07/21.
//

import Foundation

private let PRIVACY_POLICIES    = "https://www.dgc.gov.it/web/pn.html"
private let FAQ                 = "https://www.dgc.gov.it/web/faq.html#verifica19"
private let HOW_TO              = "https://www.dgc.gov.it/web/faq.html#verifica19"
private let WHY_NOT_VALID       = "https://www.dgc.gov.it/web/faq.html#verifica19"
private let VALIDITY_RANGE      = "https://www.dgc.gov.it/web/faq.html#verifica19"
private let WHICH_QR            = "https://www.dgc.gov.it/web/faq.html#verifica19"
private let ERROR_MEANING       = "https://www.dgc.gov.it/web/faq.html#verifica19"
private let SCAN_TIMES          = "https://www.dgc.gov.it/web/faq.html#verifica19"
private let STORE               = "itms-apps://apple.com/app/id1565800117"

extension Link {
    
    var url: String {
        switch self {
        case .faq:                  return FAQ
        case .privacyPolicy:        return PRIVACY_POLICIES
        case .store:                return STORE
        case .whatCanBeDone:        return HOW_TO
        case .whyQrNotValid:        return WHY_NOT_VALID
        case .qrValidityRange:      return VALIDITY_RANGE
        case .whichQrScan:          return WHICH_QR
        case .scanErrorMeaning:     return ERROR_MEANING
        case .scanTimesNeeded:      return SCAN_TIMES
        }
    }
    
    var title: String {
        switch self {
        case .faq:                  return "links.read.faq"
        case .privacyPolicy:        return "links.read.privacy.policy"
        case .store:                return "link.go.to.store"
        case .whatCanBeDone:        return "links.what.can.be.done"
        case .whyQrNotValid:        return "links.why.qr.code.not.valid"
        case .qrValidityRange:      return "links.qr.code.validity.range"
        case .whichQrScan:          return "links.which.qr.code.scan"
        case .scanErrorMeaning:     return "links.scan.error.meaning"
        case .scanTimesNeeded:      return "links.scan.times.needed"
        }
    }
    
}


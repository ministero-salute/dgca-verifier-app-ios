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
//  Link+Values.swift
//  Verifier
//
//  Created by Andrea Prosseda on 28/07/21.
//

import Foundation

private let PRIVACY_POLICIES            = "https://www.dgc.gov.it/web/pn.html"
private let FAQ                         = "https://www.dgc.gov.it/web/app.html"
private let HOW_TO                      = "https://www.dgc.gov.it/web/faq.html#verifica19"
private let WHY_NOT_VALID               = "https://www.dgc.gov.it/web/faq.html#verifica19"
private let VALIDITY_RANGE              = "https://www.dgc.gov.it/web/faq.html#verifica19"
private let WHICH_QR                    = "https://www.dgc.gov.it/web/faq.html#verifica19"
private let STORE                       = "itms-apps://apple.com/app/id1565800117"
private let WHY_VERIFICATION_NEEDED     = "https://www.dgc.gov.it/web/faq.html#verifica19"

extension Link {
    
    var url: String {
        switch self {
        case .faq:                      return FAQ
        case .privacyPolicy:            return PRIVACY_POLICIES
        case .store:                    return STORE
        case .whatCanBeDone:            return HOW_TO
        case .whyQrNotValid:            return WHY_NOT_VALID
        case .qrValidityRange:          return VALIDITY_RANGE
        case .whichQrScan:              return WHICH_QR
        case .whyVerificationNeeded:    return WHY_VERIFICATION_NEEDED
        }
    }
    
    var title: String {
        switch self {
        case .faq:                      return "links.read.faq"
        case .privacyPolicy:            return "links.read.privacy.policy"
        case .store:                    return "link.go.to.store"
        case .whatCanBeDone:            return "links.what.can.be.done"
        case .whyQrNotValid:            return "links.why.qr.code.not.valid"
        case .qrValidityRange:          return "links.qr.code.validity.range"
        case .whichQrScan:              return "links.which.qr.code.scan"
        case .whyVerificationNeeded:    return "links.why.qr.code.verification.needed"
        }
    }
    
}


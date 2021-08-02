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
//  ResultViewModel.swift
//  verifier-ios
//
//

import Foundation
import SwiftDGC

enum Status {
    case valid
    case expired
    case future
    case notValid
    case invalidQR
    case notDCC
}

func validateWithMedicalRules(_ hcert: HCert?) -> Status {
    guard let hcert = hcert else { return .notValid }
    switch hcert.type {
    case .test:
        let testValidityCheck = TestValidityCheck()
        return testValidityCheck.isTestValid(hcert)
    case .vaccine:
        let vaccineValidityCheck = VaccineValidityCheck()
        return vaccineValidityCheck.isVaccineDateValid(hcert)
    case .recovery:
        let recoveryValidityCheck = RecoveryValidityCheck()
        return recoveryValidityCheck.isRecoveryValid(hcert)
    case .unknown:
        return .notValid
    }
}

class VerificationViewModel {

    var status: Status = .invalidQR
    var hCert: HCert?
        
    init(qrCodeText: String) {
        guard let cert = HCert(from: qrCodeText) else {
            status = .notDCC
            return
        }
        guard isValid(cert) else { return }
        
        hCert = cert
        status = validateWithMedicalRules(cert)
    }

    private func isValid(_ hCert: HCert) -> Bool {
//        return cert.isValid // it checks some medical rules too.
        guard hCert.cryptographicallyValid else { return false }
        guard hCert.exp >= HCert.clock else { return false }
        guard hCert.iat <= HCert.clock else { return false }
        guard hCert.statement != nil else { return false }
        return true
    }

    var imageName: String {
        switch status {
        case .valid:
            return "icon_checkmark-filled"
        case .notDCC:
            return "icon_warning"
        case .expired, .future, .invalidQR, .notValid:
            return "icon_misuse"
        }
    }
    var title: String {
        switch status {
        case .valid:
            return "result.valid.title".localized
        case .notDCC:
            return "result.notDCC.title".localized
        case .expired, .future, .invalidQR, .notValid:
            return "result.invalid.title".localized
        }
    }
    var description: String {
        switch status {
        case .valid:
            return "result.valid.description".localized
        case .expired:
            return "result.expired.description".localized
        case .future:
            return "result.future.description".localized
        case .invalidQR:
            return "result.invalidQR.description".localized
        case .notValid:
            return "result.notValid.description".localized
        case .notDCC:
            return "result.notDCC.description".localized
        }
    }
    var validationDateTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm',' dd/MM/yyyy"
        let date = Date()
        return "result.validationDateTime".localized + dateFormatter.string(from: date)
    }
    var rescanButtonTitle: String {
        return status == .valid ? "result.nextScan".localized : "result.rescan".localized
    }
    
    var resultItems: [ResultItem]? {
        if status == .invalidQR || status == .notDCC {
            return nil
        }
        
        let firstName = hCert?.firstName ?? ""
        let lastName = hCert?.lastName ?? ""
        
        return [
            ResultItem(title: lastName + " " + firstName, subtitle: "", imageName: "icon_user"),
            ResultItem(title: "result.bithdate".localized, subtitle: birthDateString, imageName: "icon_calendar")
        ]
    }
    
    var birthDateString: String? {
        guard let dateOfBirth = hCert?.dateOfBirth else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: dateOfBirth) else { return nil }
        let italianDateFormatter = DateFormatter()
        italianDateFormatter.dateFormat = "dd/MM/yyyy"
        return italianDateFormatter.string(from: date)
    }
}

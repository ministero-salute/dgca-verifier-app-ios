//
//  VerificationState.swift
//  Verifier
//
//  Created by Emilio Apuzzo on 25/02/22.
//

import Foundation
import SwiftDGC

class VerificationState {
    
    static let shared = VerificationState()
    
    private init() {}
    
    var hCert: HCert?
    
    ///    Describes whether or not the user tapped the *second scan button*.
    var isFollowUpScan: Bool             = false
    ///    Describes whether or not the follow up molecular/rapid test was scanned.
    var followUpTestScanned: Bool         = false
    ///    Describes whether or not the user tapped the *back button* before scanning the molecular/rapid test.
    var userCanceledSecondScan: Bool     = false
    
    ///    Resets all state variables to `false`.
    public func reset() -> Void {
        self.isFollowUpScan = false
        self.followUpTestScanned = false
        self.userCanceledSecondScan = false
    }
    
    ///    Determines whether or not the `VerificationViewModel` should validate by test only or not.
    public func shouldValidateTestOnly() -> Bool {
        //    If the user canceled the test scan, the `.verificationIsNeeded` page has to be shown again.
        //    If the user did not tap the second scan button, do not validate by test only.
        return self.isFollowUpScan && !self.userCanceledSecondScan
    }

}

//
//  DebugViewModel.swift
//  VerificaC19
//
//  Created by Johnny Bueti on 07/12/21.
//

import Foundation

class DebugViewModel {
    private var publicKeys: [String]?
    
    public func getUCVICount() -> Int {
        return CRLDataStorage.crlTotalNumber()
    }
    
    public func getKIDCount() -> Int {
        return self.getPublicKeys().count
    }
    
    public func getPublicKeys() -> [String] {
        if self.publicKeys == nil {
            self.publicKeys = Array<String>(LocalData.sharedInstance.encodedPublicKeys.keys)
        }
        
        return self.publicKeys!
    }
    
    public func isDRLDownloadCompleted() -> Bool {
        return CRLDataStorage.shared.isCRLDownloadCompleted
    }
}

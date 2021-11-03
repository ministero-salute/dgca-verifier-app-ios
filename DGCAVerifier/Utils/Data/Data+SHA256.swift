//
//  Data+SHA256.swift
//  Verifier
//
//  Created by Davide Aliti on 20/08/21.
//

import Foundation
import CommonCrypto

extension Data{
    public func sha256() -> String{
        return base64StringFromData(input: digest(input: self as NSData))
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func base64StringFromData(input: NSData) -> String {
       return input.base64EncodedString()
    }
}

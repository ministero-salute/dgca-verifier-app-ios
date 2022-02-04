//
//  TestModel.swift
//  VerifierTests
//
//  Created by Emilio Apuzzo on 04/02/22.
//

import Foundation
import SwiftDGC
@testable import VerificaC19

struct TestCase: Codable, Equatable {
    static func == (lhs: TestCase, rhs: TestCase) -> Bool {
        guard lhs.expectedValidity.count == rhs.expectedValidity.count else { return false }
        return lhs.expectedValidity.enumerated()
            .map { rhs.expectedValidity[$0] == $1 }
            .filter {!$0}.isEmpty
    }
    
    let id: String
    let description: String
    let expectedValidity: [ExpectedValidity]
    var actualValidity: [ExpectedValidity]?
    let payload: String
    
    
    func report() -> String {
        guard let actualValidity = actualValidity else {return ""}
        let result: [Bool] = expectedValidity.enumerated().map{actualValidity[$0] == $1}
        let returnString = "TestCase id: \(self.id) \n"
        guard !result.filter({!$0}).isEmpty else { return returnString + " OK "}
        return returnString + expectedValidity.enumerated().map{ (index, validity) -> String in
            let result = "Modalità \(validity.mode), atteso: \(validity.result), attuale:\(actualValidity[index].result)"
            return result
        }.joined(separator: "\n")
    }
}

struct ExpectedValidity: Codable, Equatable {
    let mode: String
    let result: String
    
    func parseScanMode() -> ScanMode?{
        switch self.mode {
        case "base":
            return .base
        case "rafforzata":
            return .reinforced
        default:
            return nil
        }
    }
    
    init(mode: String, status: Status){
        self.mode = mode
        switch status {
        case .notGreenPass:
            self.result = "notGreenPass"
        case .notValid:
            self.result = "notValid"
        case .valid:
            self.result = "valid"
        case .notValidYet:
            self.result = "notValidYet"
        case .verificationIsNeeded:
            self.result = "verificationIsNeeded"
        case .revokedGreenPass:
            self.result = "revokedGreenPass"
        }
        
    }
}

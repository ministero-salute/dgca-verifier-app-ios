//
//  AutomatedTests.swift
//  VerifierTests
//
//  Created by Emilio Apuzzo on 04/02/22.
//

import XCTest
@testable import VerificaC19
@testable import SwiftDGC
import SwiftyJSON

class AutomatedTests: XCTestCase {
    
    var testCases = [TestCase]()
    var resultTestCases = [TestCase]()
    
    override func setUpWithError() throws {
        guard let path = Bundle(for: AutomatedTests.self).url(forResource: "API", withExtension: "json") else { return }
        do {
            let data = try Data(contentsOf: path)
            self.testCases = try JSONDecoder().decode([TestCase].self, from: data)
//            print("API parse result: ", self.testCases)
        }
        catch { print(error) }
    }

    override func tearDownWithError() throws {
        testCases = []
    }
    
    func test(){
        print("test")
        for index in testCases.indices {
            var actualValidityArray = [ExpectedValidity]()
            for validity in testCases[index].expectedValidity {
                guard let hCert = HCert(from: testCases[index].payload), let scanMode = validity.parseScanMode() else {
                    continue
                    // Creare struttura errore
                    
                }
                guard let validator = getValidator(for: hCert, scanMode: scanMode) else {continue}
                let result = validator.validate(hcert: hCert)
                actualValidityArray.append(ExpectedValidity(mode: validity.mode, status: result))
                print("result for test id \(testCases[index].id) and validity: \(validity.mode) :", result)
            }
            testCases[index].actualValidity = actualValidityArray
        }
        
        getReport()
        
        for testCase in testCases{
            XCTAssertEqual(testCase.actualValidity, testCase.expectedValidity)
        }
        
        print("end")
    }
    
    func getValidator(for hCert: HCert, scanMode: ScanMode) -> DGCValidator? {
        return DGCValidatorBuilder().checkHCert(false).scanMode(scanMode).build(hCert: hCert)
    }
    
    func getReport(){
        testCases.forEach { testCase in
            print (testCase.report())
        }
    }
    
}

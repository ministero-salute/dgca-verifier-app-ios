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
    
    override func setUpWithError() throws {
        guard let path = Bundle(for: AutomatedTests.self).url(forResource: "xxx", withExtension: "json") else { return }
        do {
            let data = try Data(contentsOf: path)
            self.testCases = try JSONDecoder().decode([TestCase].self, from: data)
        }
        catch { print(error) }
    }

    override func tearDownWithError() throws {
        testCases = []
    }
    
    func test() {
       
        for index in testCases.indices {
            var actualValidity = [TestResult]()
            for validity in testCases[index].expectedValidity {
                guard let hCert = HCert(from: testCases[index].payload), let scanMode = validity.parseScanMode() else {
                    continue
                    // Creare struttura errore
                    
                }
                guard let validator = getValidator(for: hCert, scanMode: scanMode) else {continue}
                let result = validator.validate(hcert: hCert)
                actualValidity.append(TestResult(mode: validity.mode, status: result))
            }
            testCases[index].actualValidity = actualValidity
        }
        
        let report = testCases.map{ $0.report() }
        if let encodedData = try? JSONEncoder().encode(report) {
            let json = String(data: encodedData, encoding: String.Encoding.utf8)
            print("report = \(json ?? "{}")")
        }
        
        testCases.forEach{ XCTAssertEqual($0.actualValidity, $0.expectedValidity)}
    }
    
    func getValidator(for hCert: HCert, scanMode: ScanMode) -> DGCValidator? {
        return DGCValidatorBuilder().checkHCert(false).scanMode(scanMode).build(hCert: hCert)
    }
 

}

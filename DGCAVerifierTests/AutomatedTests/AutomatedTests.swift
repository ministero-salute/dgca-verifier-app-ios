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
import SwiftUI

class AutomatedTests: XCTestCase {
    
    var testCases = [TestCase]()
    
    let scanModeCols = ["Base", "Rafforzata", "Visitatori RSA", "Studenti", "Lavoro", "Ingresso in italia"]
    
    //Descrizione;ID;Payload;Base;Rafforzata;Visitatori RSA;Studenti;Lavoro;Ingresso in italia
    private func loadTestArrayfromCSV(fromURL url: URL, rowSeparator: String = "\r", colSeparator: String = ";") -> [TestCase] {
        guard let csv = try? String(contentsOf: url, encoding: .utf8) else { return [] }
        let rows = csv.components(separatedBy: rowSeparator)
        guard rows.count > 1 else { return [] }

        let rowsWithoutHeader = Array<String>(rows[1..<rows.count])
        return rowsWithoutHeader.map{
            let fields = $0.components(separatedBy: colSeparator)
            let desc = fields[0]
            let id = fields[1]
            let payload = fields[2]
            let expectedValidity: [TestResult] = Array<String>(fields[3..<fields.count])
                .enumerated()
                .compactMap{
                    guard $1.count > 0 else { return nil }
                    return TestResult(mode: scanModeCols[$0], result: $1)
                }
            
            return TestCase(id: id, desc: desc, expectedValidity: expectedValidity, actualValidity: nil, payload: payload)
        }
    }
    
    private func loadTestArrayfromJSON(fromURL url: URL) -> [TestCase] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        guard let array = try? JSONDecoder().decode([TestCase].self, from: data) else { return [] }
        return array
    }
        
    override func setUpWithError() throws {
        guard let url = Bundle(for: AutomatedTests.self).url(forResource: "CasiDiTest", withExtension: "csv") else { return }
        self.testCases = loadTestArrayfromCSV(fromURL: url)
        //self.testCases = loadTestArrayfromJSON(fromURL: url)
    }

    override func tearDownWithError() throws {
        testCases = []
    }
    
    func test() {
        
        for index in testCases.indices {
            var actualValidity = [TestResult]()
            guard let hCert = HCert(from: testCases[index].payload) else { continue }
            
            for validity in testCases[index].expectedValidity {
                guard let scanMode = validity.scanMode() else { continue }
                guard let validator = getValidator(for: hCert, scanMode: scanMode) else {continue}
                let result = validator.validate(hcert: hCert)
                actualValidity.append(TestResult(mode: validity.mode, status: result))
            }
            testCases[index].actualValidity = actualValidity
        }
        printTestsReport()
//
//        testCases.forEach{ XCTAssertEqual($0.actualValidity, $0.expectedValidity)}
    }
    
    func printTestsReport() {
        //let reports = testCases.map{ $0.report() }
//        if let encodedData = try? JSONEncoder().encode(report) {
//            let json = String(data: encodedData, encoding: String.Encoding.utf8)
//            print("report = \(json ?? "{}")")
//        }
        
        //Descrizione;ID;Payload;Base;Rafforzata;Visitatori RSA;Studenti;Lavoro;Ingresso in italia
        testCases.map{ testCase in
            let results = scanModeCols.map{ scanMode in
                testCase.actualValidity?.filter{ $0.mode == scanMode }.first?.result ?? ""
            }.joined(separator: ";")
            
            return "\(testCase.desc);\(testCase.id);...;\(results)"
        }
        .forEach{ print($0)}
        
    }
    
    func getValidator(for hCert: HCert, scanMode: ScanMode) -> DGCValidator? {
        return DGCValidatorBuilder().checkHCert(false).scanMode(scanMode).build(hCert: hCert)
    }
 

}

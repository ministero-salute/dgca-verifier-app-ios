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
    
    let scanModeCols = ["Base", "Rafforzata", "Visitatori RSA", "Studenti", "Lavoro", "Ingresso in italia"]
    
    private func loadTestArrayfromCSV(fromURL url: URL, rowSeparator: String = "\r", colSeparator: String = ";") -> [TestCase] {
        guard let csv = try? String(contentsOf: url, encoding: .utf8) else { return [] }
        let rows = csv.components(separatedBy: rowSeparator)
        guard rows.count > 1 else { return [] }

        let rowsWithoutHeader = Array<String>(rows[1..<rows.count])
        return rowsWithoutHeader.compactMap {
			guard $0 != "" else { return nil }
			
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
	
	private func loadMockedSettings() {
		guard let mockedSettingsURL = Bundle(for: AutomatedTests.self).url(forResource: "mockedSettings", withExtension: "json") else { return }
		guard let mockedSettingsData = try? Data(contentsOf: mockedSettingsURL) else { return }
		guard let mockedSettings = try? JSONDecoder().decode([Setting].self, from: mockedSettingsData) else { return }
		
		mockedSettings.forEach{ mockedSetting in
			SettingDataStorage.sharedInstance.addOrUpdateSettings(mockedSetting)
		}
	}
        
    override func setUpWithError() throws {
        guard let url = Bundle(for: AutomatedTests.self).url(forResource: "CasiDiTest", withExtension: "csv") else { return }
        self.testCases = loadTestArrayfromCSV(fromURL: url, rowSeparator: "\n")
		
		self.loadMockedSettings()
    }

    override func tearDownWithError() throws {
        testCases = []
    }
    
    func test() {
		
		for index in self.testCases.indices {
			// Set this to the test case ID you would like to debug to filter out any other case
			let debugTestCaseID: String? = nil
			
			if debugTestCaseID != nil {
				if self.testCases[index].id != debugTestCaseID {
					continue
				}
			}
			
			var actualValidity = [TestResult]()
			guard let hCert = HCert(from: self.testCases[index].payload) else { continue }
			
			for validity in self.testCases[index].expectedValidity {
				guard let scanMode = validity.scanMode() else { continue }
				guard let validator = self.getValidator(for: hCert, scanMode: scanMode) else {continue}
				let result = validator.validate(hcert: hCert)
				actualValidity.append(TestResult(mode: validity.mode, status: result))
			}
			self.testCases[index].actualValidity = actualValidity
		}
		
		print(self.printTestsReport())
		
    }
    
    func printTestsReport() {
        
        print("Descrizione;ID;Payload;Base;Rafforzata;Visitatori RSA;Studenti;Lavoro;Ingresso in italia\n")
        testCases.map{ testCase in
            let results = scanModeCols.map{ scanMode in
				let actualValidity = testCase.actualValidity?.filter{ $0.mode == scanMode }.first?.result ?? ""
				let expectedValidity = testCase.expectedValidity.filter{ $0.mode == scanMode }.first?.result ?? ""
				let result = (actualValidity == expectedValidity) ? "[OK]" : "[KO]"
				let shouldEchoResult = !(["", " "].contains(expectedValidity))
				return shouldEchoResult ? "\(result) \(expectedValidity) -> \(actualValidity)" : ""
            }.joined(separator: ";")
            
            return "\(testCase.desc);\(testCase.id);...;\(results)"
        }
        .forEach{ print($0)}
        
    }
    
    func getValidator(for hCert: HCert, scanMode: ScanMode) -> DGCValidator? {
        return DGCValidatorBuilder().checkHCert(false).scanMode(scanMode).build(hCert: hCert)
    }
 

}

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
//  TestValidityCheckTests.swift
//  VerifierTests
//
//  Created by Davide Aliti on 08/06/21.
//

import XCTest
@testable import VerificaC19
@testable import SwiftDGC
import SwiftyJSON

class TestValidityCheckTests: XCTestCase {
    
    var hcert: HCert!
    var payload: String!
    var bodyString: String!

    
    private func getValidator(mode: ScanMode, hCert: HCert) -> DGCValidator? {
        ValidatorProducer.getProducer(scanMode: mode)?.getValidator(hcert: hcert)
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        payload = "HC1:6BFOXN%TS3DHPVO13J /G-/2YRVA.Q/R8H:I2FCJG9AE1O/CGJ9-J3P+GY P8L6IWM$S4U45P84HW6U/4:84LC6 YM::QQHIZC4.OI:OIG/Q80PWW2G%89-8CNNM3LO%0WA46+8F/8A.A94LVZ0H*AYZ0MKNAB5S.8%*8Z95NEL6T98VA8YISLV423VLJ0JBIFT/1541TS+0C4TV*C*K5-ZVMHFIFT.HBC77PM5LXK$4JSZ4P:45/GK%I74J9.SXTC69TQ0SG JK423UJ*IBLOIWHSJZI+EBI.CHFTQMCA.SF*SSMCU3TNQ4TR9Y$H5%HTR9C/P0Q3%*JMY54W1XYH9W1OH6NFEYY57Q4UYQD*O%+Q.SQBDO3KLB75EHPSGO0IQOGOE34L/5R3FOKEH-BK2L88LNUMD78*7LMIAK/BGP95MG/IC3DAF:F6LF7E9Y7M-CI73A3 9-QDSRD1PC6LFE1KEJC%:CMNSQ98N:21 2O*4R60NM8JI0EUGP$I/XK$M8ZQE6YB9M66P8N31TMC3FD5I7NZLDMOCY7H6UPC9A7I*-E Y7-XPZP5CWQXAUHO6O5M1-V1ENE*N +2:ONETEKTFV5ENQMHZF.+E:OUL4NLEQY$HPMGP2G/20165T1"
        hcert = HCert(from: payload)
        bodyString = "{\"6\": 1620925844, \"1\": \"Ministero della Salute\", \"4\": 1628591235, \"-260\": {\"1\": {\"nam\": {\"gn\": \"Marilù Teresa\", \"fnt\": \"DI<CAPRIO\", \"fn\": \"Di Caprio\", \"gnt\": \"MARILU<TERESA\"}, \"dob\": \"1977-06-16\", \"ver\": \"1.0.0\", \"t\": [{\"is\": \"Ministero della Salute\", \"co\": \"IT\", \"tt\": \"LP217198-3\", \"nm\": \"Panbio COVID-19 Ag Test\", \"sc\": \"2021-05-03T12:27:15+02:00\", \"ma\": \"1232\", \"tg\": \"840539006\", \"tr\": \"260415000\", \"ci\": \"01IT2BABF46FEBF44512A28516DA5B59C122#0\", \"tc\": \"Policlinico Umberto I\", \"dr\": \"2021-05-03T14:27:15+02:00\"}]}}}"
        SettingDataStorage.sharedInstance.settings = []
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        payload = nil
        hcert = nil
        bodyString = nil
        SettingDataStorage.sharedInstance.settings = []
    }

    func testValidNegativeTest() {
		let testSettingStartDay = Setting(name: Constants.rapidStartHoursKey, type: "GENERIC", value: "0")
		let testSettingEndDay = Setting(name: Constants.rapidEndHoursKey, type: "GENERIC", value: "48")
		SettingDataStorage.sharedInstance.addOrUpdateSettings(testSettingStartDay)
		SettingDataStorage.sharedInstance.addOrUpdateSettings(testSettingEndDay)
		
		bodyString = bodyString.replacingOccurrences(
			of: "\"sc\": \"2021-05-03T12:27:15+02:00\"",
			with: "\"sc\": \"\(Date().toDateTimeString)\""
		)
		hcert.body = JSON(parseJSON: bodyString)[ClaimKey.hCert.rawValue][ClaimKey.euDgcV1.rawValue]
		
        let isTestNegativeResult = getValidator(mode: .base, hCert: hcert)?.validate(hcert: hcert)
    
        XCTAssertEqual(isTestNegativeResult, .valid)
    }
    
    func testInvalidPositiveTest() {
        bodyString = bodyString.replacingOccurrences(of: "\"tr\": \"260415000\"", with: "\"tr\": \"260373001\"")
        hcert.body = JSON(parseJSON: bodyString)[ClaimKey.hCert.rawValue][ClaimKey.euDgcV1.rawValue]
        let isTestNegativeResult = getValidator(mode: .base, hCert: hcert)?.validate(hcert: hcert)
    
        XCTAssertEqual(isTestNegativeResult, .notValid)
    }
    
    func testValidRapidTestDate() {
        let testSettingStartDay = Setting(name: "rapid_test_start_hours", type: "GENERIC", value: "0")
        let testSettingEndDay = Setting(name: "rapid_test_end_hours", type: "GENERIC", value: "1")
        SettingDataStorage.sharedInstance.addOrUpdateSettings(testSettingStartDay)
        SettingDataStorage.sharedInstance.addOrUpdateSettings(testSettingEndDay)
        let todayDateFormatted = Date().toDateTimeString
        bodyString = bodyString.replacingOccurrences(of: "\"sc\": \"2021-05-03T12:27:15+02:00\"", with: "\"sc\": \"\(todayDateFormatted)\"")
        hcert.body = JSON(parseJSON: bodyString)[ClaimKey.hCert.rawValue][ClaimKey.euDgcV1.rawValue]
        let isTestDateValidResult = getValidator(mode: .base, hCert: hcert)?.validate(hcert: hcert)
        
        XCTAssertEqual(isTestDateValidResult, .valid)
    }
    
    func testFutureRapidTestDate() {
        let testSettingStartDay = Setting(name: "rapid_test_start_hours", type: "GENERIC", value: "0")
        let testSettingEndDay = Setting(name: "rapid_test_end_hours", type: "GENERIC", value: "1")
        SettingDataStorage.sharedInstance.addOrUpdateSettings(testSettingStartDay)
        SettingDataStorage.sharedInstance.addOrUpdateSettings(testSettingEndDay)
        let futureDateFormatted = Date().add(2, ofType: .hour)?.toDateTimeString ?? ""
        bodyString = bodyString.replacingOccurrences(of: "\"sc\": \"2021-05-03T12:27:15+02:00\"", with: "\"sc\": \"\(futureDateFormatted)\"")
        hcert.body = JSON(parseJSON: bodyString)[ClaimKey.hCert.rawValue][ClaimKey.euDgcV1.rawValue]
        let isTestDateValidResult = getValidator(mode: .base, hCert: hcert)?.validate(hcert: hcert)
        
        XCTAssertEqual(isTestDateValidResult, .notValidYet)
    }
    
    func testMissingSettingRapidTestDate() {
        hcert.body = JSON(parseJSON: bodyString)[ClaimKey.hCert.rawValue][ClaimKey.euDgcV1.rawValue]
        let isTestDateValidResult = getValidator(mode: .base, hCert: hcert)?.validate(hcert: hcert)

        XCTAssertEqual(isTestDateValidResult, .notGreenPass)
    }
    
    func testNotOver50YMD() {
        
        let testSettingStartDay = Setting(name: "rapid_test_start_hours", type: "GENERIC", value: "0")
        let testSettingEndDay = Setting(name: "rapid_test_end_hours", type: "GENERIC", value: "1")
        SettingDataStorage.sharedInstance.addOrUpdateSettings(testSettingStartDay)
        SettingDataStorage.sharedInstance.addOrUpdateSettings(testSettingEndDay)
        
        let todayDateFormatted = Date().toDateTimeString
        bodyString = bodyString.replacingOccurrences(of: "\"sc\": \"2021-05-03T12:27:15+02:00\"", with: "\"sc\": \"\(todayDateFormatted)\"")
        
        bodyString = bodyString.replacingOccurrences(of: "\"dob\": \"1977-06-16\"", with: "\"dob\": \"1996-01-01\"")
        Store.set(Constants.scanMode50, for: .scanMode)
        
        hcert.body = JSON(parseJSON: bodyString)[ClaimKey.hCert.rawValue][ClaimKey.euDgcV1.rawValue]
                
        print("[TEST] \(hcert.birthDate)")
        
        let isTestDateValidResult = getValidator(mode: .base, hCert: hcert)?.validate(hcert: hcert)
        XCTAssertEqual(isTestDateValidResult, .valid)
    }
    
    func testNotOver50YM() {
        
        let testSettingStartDay = Setting(name: "rapid_test_start_hours", type: "GENERIC", value: "0")
        let testSettingEndDay = Setting(name: "rapid_test_end_hours", type: "GENERIC", value: "1")
        SettingDataStorage.sharedInstance.addOrUpdateSettings(testSettingStartDay)
        SettingDataStorage.sharedInstance.addOrUpdateSettings(testSettingEndDay)
        
        let todayDateFormatted = Date().toDateTimeString
        bodyString = bodyString.replacingOccurrences(of: "\"sc\": \"2021-05-03T12:27:15+02:00\"", with: "\"sc\": \"\(todayDateFormatted)\"")
        
        bodyString = bodyString.replacingOccurrences(of: "\"dob\": \"1977-06-16\"", with: "\"dob\": \"1996-01\"")
        Store.set(Constants.scanMode50, for: .scanMode)
        
        hcert.body = JSON(parseJSON: bodyString)[ClaimKey.hCert.rawValue][ClaimKey.euDgcV1.rawValue]
                
        print("[TEST] \(hcert.birthDate)")
        
        let isTestDateValidResult = getValidator(mode: .base, hCert: hcert)?.validate(hcert: hcert)
        XCTAssertEqual(isTestDateValidResult, .valid)
    }
    
    func testNotOver50Y() {
        
        let testSettingStartDay = Setting(name: "rapid_test_start_hours", type: "GENERIC", value: "0")
        let testSettingEndDay = Setting(name: "rapid_test_end_hours", type: "GENERIC", value: "1")
        SettingDataStorage.sharedInstance.addOrUpdateSettings(testSettingStartDay)
        SettingDataStorage.sharedInstance.addOrUpdateSettings(testSettingEndDay)
        
        let todayDateFormatted = Date().toDateTimeString
        bodyString = bodyString.replacingOccurrences(of: "\"sc\": \"2021-05-03T12:27:15+02:00\"", with: "\"sc\": \"\(todayDateFormatted)\"")
        
        bodyString = bodyString.replacingOccurrences(of: "\"dob\": \"1977-06-16\"", with: "\"dob\": \"1996\"")
        Store.set(Constants.scanMode50, for: .scanMode)
        
        hcert.body = JSON(parseJSON: bodyString)[ClaimKey.hCert.rawValue][ClaimKey.euDgcV1.rawValue]
                
        print("[TEST] \(hcert.birthDate)")
        
        let isTestDateValidResult = getValidator(mode: .base, hCert: hcert)?.validate(hcert: hcert)
        XCTAssertEqual(isTestDateValidResult, .valid)
    }
    
    func testOver50YMD() {
        
        let testSettingStartDay = Setting(name: "rapid_test_start_hours", type: "GENERIC", value: "0")
        let testSettingEndDay = Setting(name: "rapid_test_end_hours", type: "GENERIC", value: "1")
        SettingDataStorage.sharedInstance.addOrUpdateSettings(testSettingStartDay)
        SettingDataStorage.sharedInstance.addOrUpdateSettings(testSettingEndDay)
        
        let todayDateFormatted = Date().toDateTimeString
        bodyString = bodyString.replacingOccurrences(of: "\"sc\": \"2021-05-03T12:27:15+02:00\"", with: "\"sc\": \"\(todayDateFormatted)\"")
        
        bodyString = bodyString.replacingOccurrences(of: "\"dob\": \"1977-06-16\"", with: "\"dob\": \"1970-01-01\"")
        Store.set(Constants.scanMode50, for: .scanMode)
        
        hcert.body = JSON(parseJSON: bodyString)[ClaimKey.hCert.rawValue][ClaimKey.euDgcV1.rawValue]
                
        print("[TEST] \(hcert.birthDate)")
        
        let isTestDateValidResult = getValidator(mode: .work, hCert: hcert)?.validate(hcert: hcert)
        XCTAssertEqual(isTestDateValidResult, .notValid)
    }
    
    func testOver50YM() {
        
        let testSettingStartDay = Setting(name: "rapid_test_start_hours", type: "GENERIC", value: "0")
        let testSettingEndDay = Setting(name: "rapid_test_end_hours", type: "GENERIC", value: "1")
        SettingDataStorage.sharedInstance.addOrUpdateSettings(testSettingStartDay)
        SettingDataStorage.sharedInstance.addOrUpdateSettings(testSettingEndDay)
        
        let todayDateFormatted = Date().toDateTimeString
        bodyString = bodyString.replacingOccurrences(of: "\"sc\": \"2021-05-03T12:27:15+02:00\"", with: "\"sc\": \"\(todayDateFormatted)\"")
        
        bodyString = bodyString.replacingOccurrences(of: "\"dob\": \"1977-06-16\"", with: "\"dob\": \"1970-01\"")
        Store.set(Constants.scanMode50, for: .scanMode)
        
        hcert.body = JSON(parseJSON: bodyString)[ClaimKey.hCert.rawValue][ClaimKey.euDgcV1.rawValue]
                
        print("[TEST] \(hcert.birthDate)")
        
        let isTestDateValidResult = getValidator(mode: .work, hCert: hcert)?.validate(hcert: hcert)
        XCTAssertEqual(isTestDateValidResult, .notValid)
    }
    
    func testOver50Y() {
        
        let testSettingStartDay = Setting(name: "rapid_test_start_hours", type: "GENERIC", value: "0")
        let testSettingEndDay = Setting(name: "rapid_test_end_hours", type: "GENERIC", value: "1")
        SettingDataStorage.sharedInstance.addOrUpdateSettings(testSettingStartDay)
        SettingDataStorage.sharedInstance.addOrUpdateSettings(testSettingEndDay)
        
        let todayDateFormatted = Date().toDateTimeString
        bodyString = bodyString.replacingOccurrences(of: "\"sc\": \"2021-05-03T12:27:15+02:00\"", with: "\"sc\": \"\(todayDateFormatted)\"")
        
        bodyString = bodyString.replacingOccurrences(of: "\"dob\": \"1977-06-16\"", with: "\"dob\": \"1970\"")
        
        Store.set(Constants.scanMode50, for: .scanMode)
        
        hcert.body = JSON(parseJSON: bodyString)[ClaimKey.hCert.rawValue][ClaimKey.euDgcV1.rawValue]
                
        print("[TEST] \(hcert.birthDate)")
        
        let isTestDateValidResult = getValidator(mode: .work, hCert: hcert)?.validate(hcert: hcert)
        XCTAssertEqual(isTestDateValidResult, .notValid)
    }

}

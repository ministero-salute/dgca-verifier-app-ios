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
//  VaccineValidityCheckTests.swift
//  VerifierTests
//
//  Created by Davide Aliti on 07/06/21.
//

import XCTest
@testable import VerificaC19
@testable import SwiftDGC
import SwiftyJSON

class VaccineValidityCheckTests: XCTestCase {
    //var vaccineValidityCheck: VaccineValidityCheck!
    var hcert: HCert!
    var payload: String!
    var bodyString: String!
    
    let vaccineStartComplete: String = "vaccine_start_day_complete_IT"
    let vaccineEndComplete: String = "vaccine_end_day_complete"
    let vaccineEndCompleteIT: String = "vaccine_end_day_complete_IT"

    private func getValidator(mode: ScanMode, hCert: HCert) -> DGCValidator? {
        var validators: [DGCValidator] = []

        let validatorBuilder = DGCValidatorBuilder()
        validatorBuilder.checkHCert = false
        
        let factory = ValidatorProducer.getProducer(scanMode: mode)
        if let validator = factory?.getValidator(hcert: hCert) {
            validators.append(validator)
        }
        let chainValidators = ChainValidator(validators: validators)
        return chainValidators
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        //Store.set(Constants.scanMode3G, for: .scanMode)
        payload = "HC1:6BFOXN%TS3DHPVO13J /G-/2YRVA.Q/R82JD2FCJG96V75DOW%IY17EIHY P8L6IWM$S4U45P84HW6U/4:84LC6 YM::QQHIZC4.OI1RM8ZA.A5:S9MKN4NN3F85QNCY0O%0VZ001HOC9JU0D0HT0HB2PL/IB*09B9LW4T*8+DCMH0LDK2%KI*V AQ2%KYZPQV6YP8722XOE7:8IPC2L4U/6H1D31BLOETI0K/4VMA/.6LOE:/8IL882B+SGK*R3T3+7A.N88J4R$F/MAITHW$P7S3-G9++9-G9+E93ZM$96TV6QRR 1JI7JSTNCA7G6MXYQYYQQKRM64YVQB95326FW4AJOMKMV35U:7-Z7QT499RLHPQ15O+4/Z6E 6U963X7$8Q$HMCP63HU$*GT*Q3-Q4+O7F6E%CN4D74DWZJ$7K+ CZEDB2M$9C1QD7+2K3475J%6VAYCSP0VSUY8WU9SG43A-RALVMO8+-VD2PRPTB7S015SSFW/BE1S1EV*2Q396Q*4TVNAZHJ7N471FPL-CA+2KG-6YPPB7C%40F18N4"
        hcert = try? HCert(from: payload)
        
        bodyString = "{\"4\": 1628553600, \"6\": 1620926082, \"1\": \"Ministero della Salute\", \"-260\": {\"1\": {\"ver\": \"1.0.0\", \"dob\": \"1977-06-16\", \"v\": [{\"ma\": \"ORG-100030215\", \"sd\": 2, \"dt\": \"2021-06-08\", \"co\": \"IT\", \"ci\": \"01IT67DA8332EF2C4E6780ABA5DF078A018E#0\", \"mp\": \"EU/1/20/1528\", \"is\": \"Ministero della Salute\", \"tg\": \"840539006\", \"vp\": \"1119349007\", \"dn\": 2}], \"nam\": {\"gnt\": \"MARILU<TERESA\", \"gn\": \"Marilù Teresa\", \"fn\": \"Di Caprio\", \"fnt\": \"DI<CAPRIO\"}}}}"
        
        SettingDataStorage.sharedInstance.settings = []
        
        let VaccineEMASetting = Setting(name: "EMA_vaccines", type: "GENERIC", value: "EU/1/20/1525;EU/1/20/1507;EU/1/20/1528;EU/1/21/1529;Covishield;R-COVI;Covid-19-recombinant")

        SettingDataStorage.sharedInstance.addOrUpdateSettings(VaccineEMASetting)
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        //vaccineValidityCheck = nil
        payload = nil
        hcert = nil
        bodyString = nil
        SettingDataStorage.sharedInstance.settings = []
    }
    
    func testGetDosesString() {
        let vaccineDosesArray = [hcert.currentDosesNumber, hcert.totalDosesNumber]
        
        XCTAssertEqual(vaccineDosesArray.count, 2)
        XCTAssertEqual(vaccineDosesArray[0], 2)
        XCTAssertEqual(vaccineDosesArray[1], 2)
    }
    
    func testValidVaccineDate() {
        
        guard let vaccinationDate = hcert.vaccineDate?.toVaccineDate else { return }
        let passedDays = Calendar.current.dateComponents([.day], from: Date(), to: vaccinationDate)
        guard var passedDaysInt = passedDays.day else { return }

        if passedDaysInt < 0{
            passedDaysInt = passedDaysInt * -1 + 3
        }
        else {
            passedDaysInt = passedDaysInt + 3
        }
        
        let passedDaysString = passedDaysInt.stringValue
        
        let vaccineSettingStartDay = Setting(name: self.vaccineStartComplete, type: "EU/1/20/1528", value: "0")
        let vaccineSettingEndDayIT = Setting(name: self.vaccineEndCompleteIT, type: "EU/1/20/1528", value: passedDaysString)
        let vaccineSettingEndDay = Setting(name: self.vaccineEndComplete, type: "EU/1/20/1528", value: passedDaysString)
        SettingDataStorage.sharedInstance.addOrUpdateSettings(vaccineSettingStartDay)
        SettingDataStorage.sharedInstance.addOrUpdateSettings(vaccineSettingEndDayIT)
        SettingDataStorage.sharedInstance.addOrUpdateSettings(vaccineSettingEndDay)
        
        let isVaccineDateValidResult = getValidator(mode: .base, hCert: hcert)?.validate(hcert: hcert)
        
        XCTAssertEqual(isVaccineDateValidResult, .valid)
    }
    
    func testFutureVaccineDate() {
       
        guard let vaccinationDate = hcert.vaccineDate?.toVaccineDate else { return }
        let passedDays = Calendar.current.dateComponents([.day], from: Date(), to: vaccinationDate)
        guard var passedDaysInt = passedDays.day else { return }

        if passedDaysInt < 0{
            passedDaysInt = passedDaysInt * -1 + 1
        }
        else {
            passedDaysInt = passedDaysInt + 1
        }
        
        let passedDaysString = passedDaysInt.stringValue
        
        let vaccineSettingStartDay = Setting(name: self.vaccineStartComplete, type: "EU/1/20/1528", value: "0")
        let vaccineSettingEndDayIT = Setting(name: self.vaccineEndCompleteIT, type: "EU/1/20/1528", value: passedDaysString)
        let vaccineSettingEndDay = Setting(name: self.vaccineEndComplete, type: "EU/1/20/1528", value: passedDaysString)
        
        SettingDataStorage.sharedInstance.addOrUpdateSettings(vaccineSettingStartDay)
        SettingDataStorage.sharedInstance.addOrUpdateSettings(vaccineSettingEndDayIT)
        SettingDataStorage.sharedInstance.addOrUpdateSettings(vaccineSettingEndDay)
        
        let isVaccineDateValidResult = getValidator(mode: .base, hCert: hcert)?.validate(hcert: hcert)
        
        XCTAssertEqual(isVaccineDateValidResult, .valid)
    }

}

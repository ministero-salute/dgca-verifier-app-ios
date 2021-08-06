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
//  LocalDataTests.swift
//  VerifierTests
//
//  Created by Davide Aliti on 09/06/21.
//

import XCTest
@testable import VerificaC19

class LocalDataTests: XCTestCase {
    var encodedPublicKey: String!
    var setting: Setting!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        SettingDataStorage.sharedInstance.settings = []
        LocalData.sharedInstance.encodedPublicKeys = [:]
        encodedPublicKey = "MIIEFzCCAf8CAhI8MA0GCSqGSIb3DQEBBAUAMIGDMQswCQYDVQQGEwJYWDEaMBgGA1UECAwRRXVyb3BlYW4gQ29tbWlzb24xETAPBgNVBAcMCEJydXNzZWxzMQ4wDAYDVQQKDAVESUdJVDEUMBIGA1UECwwLUGVuIFRlc3RpbmcxHzAdBgNVBAMMFlBlbiBUZXN0ZXJzIEFDQyAoQ1NDQSkwHhcNMjEwNTA3MTM0MTE0WhcNMjIwNTA3MTM0MTE0WjAeMQswCQYDVQQGEwJYWDEPMA0GA1UEAwwGUm9iZXJ0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqrScBZXVoF4+UcbE8+eRVMsDjvdA9CvxE+f077zYJ6/xaVzNooafTvWI/QHCxNKT8diNoo1uylhvbvCY1sWsjPwCFkTJE49LGm5IetPRHX9zKTsd+fyMj2+yQxx3tkj6d9jO6hmozJhjxSMGvV0IyXIv3fsXHH3kOHpT43mf9MxFBYua4Qxci0RgGYCIJSwZk9jiHRKAFFiDf5hMcqmcezzcMDJc17FhJ7TenqbtzVfr3L9yzZLURqDylVeOit/w5PGyN+KhJRGjPqReqreaFGQsviy3VVf0wKfKMOovHobj7+DYBpyXFuUKE6u0P+3NQfnwwzt6bxLasHwhSmwCCwIDAQABMA0GCSqGSIb3DQEBBAUAA4ICAQBiKvNcpS9aVn58UbUgRLNgOkjhzd5qby/s0bV1XHT7te7rmfoPeB1wypP4XMt6Sfz1hiQcBGTnpbox4/HPkHHGgpJ5RFdFeCUYj4oqIB+MWOqpnQxKIu2f4a2TqgoW2zdvxk9eO9kdoTbxU4xQn/Y6/Wovw29B9nCiMRwa39ZGScDRMQMTbesd/6lJYtSZyjNls2Guxv4kCy3ekFktXQzsUXIrm+Yvhe68+dPgKe26S1xLNRt3kAR30HM5kB3vM8jTGiqubOe6W6YfcX4XoVfmwVfttk2BLPl0u/SXt/SsRHWuYzJ48AUXkK6vd3HR5FG39YSvEZ1Tlf9GRmR2uXO/TnnZiGd+cyjLgAPGtjg1oq0MdzlIFsoFe9cN/XVGjkmRYZ7FzdiSn6IQWUyyoGmFN5B7Q6ZdBMAb58Z3jcTwzmkkHZlfqpUSoK+Hpah515SgjwfY5s9g8vEqefWVmLlYGAiDkfaTYUie53wCXBC+xBJBL7VJnaxqmTKWwM5cRx5uZyOUs6ZQT7CKD1SDk1+C7PAevGKNFTatFn4puITVgQ0NFiIf7ZKOy1w8Zf5aVk0vP3gfOg3SK38RgD81iLTPWr07XTfMZBTaTUr+ph6hxtwSIhHVFsF6n8adl5RynuYDfCCts5E9mOGLqC7ruMKRoOIBOPEwGS5/wIhMO7UEgQ=="
        setting = Setting(name: "testName", type: "testType", value: "testValue")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        SettingDataStorage.sharedInstance.settings = []
        LocalData.sharedInstance.encodedPublicKeys = [:]
    }

    func testAddEncodedPublicKeyForNewKid() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        LocalData.sharedInstance.add(kid: "abc", encodedPublicKey: encodedPublicKey)
        XCTAssertEqual(LocalData.sharedInstance.encodedPublicKeys.count, 1)
    }
    
    func testAddEncodedPublicKeyForExistingKid() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        LocalData.sharedInstance.encodedPublicKeys["+/bbaA9m0j0="] = ["abc"]
        LocalData.sharedInstance.add(kid: "+/bbaA9m0j0=", encodedPublicKey: encodedPublicKey)
        XCTAssertEqual(LocalData.sharedInstance.encodedPublicKeys["+/bbaA9m0j0="]!.count, 2)
    }

    func testAddNewSetting() throws {
        SettingDataStorage.sharedInstance.addOrUpdateSettings(setting)
        XCTAssertEqual(SettingDataStorage.sharedInstance.settings.count, 1)
    }
    
    func testUpdateSetting() throws {
        let setting2 = Setting(name: "testName2", type: "testType", value: "testValue")
        let setting3 = Setting(name: "testName", type: "testType2", value: "testValue")
        let setting4 = Setting(name: "testName", type: "testType", value: "testValue2")
        SettingDataStorage.sharedInstance.addOrUpdateSettings(setting)
        SettingDataStorage.sharedInstance.addOrUpdateSettings(setting2)
        XCTAssertEqual(SettingDataStorage.sharedInstance.settings.count, 2)
        SettingDataStorage.sharedInstance.addOrUpdateSettings(setting)
        SettingDataStorage.sharedInstance.addOrUpdateSettings(setting3)
        XCTAssertEqual(SettingDataStorage.sharedInstance.settings.count, 3)
        SettingDataStorage.sharedInstance.addOrUpdateSettings(setting)
        SettingDataStorage.sharedInstance.addOrUpdateSettings(setting4)
        XCTAssertEqual(SettingDataStorage.sharedInstance.settings.count, 3)
        let filteredSetting = SettingDataStorage.sharedInstance.settings.filter { return ($0.name == "testName" && $0.type == "testType") }
        XCTAssertEqual(filteredSetting.count, 1)
        XCTAssertEqual(filteredSetting[0].value, "testValue2")
    }
    
    func testGetFirstSetting() throws {
        let setting2 = Setting(name: "testName", type: "testType2", value: "testValue2")
        SettingDataStorage.sharedInstance.addOrUpdateSettings(setting)
        SettingDataStorage.sharedInstance.addOrUpdateSettings(setting2)
        let firstSetting = SettingDataStorage.sharedInstance.getFirstSetting(withName: "testName")
        XCTAssertEqual(firstSetting!, "testValue")
    }

}

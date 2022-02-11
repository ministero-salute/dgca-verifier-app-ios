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
//  Constants.swift
//  Verifier
//
//  Created by Emilio Apuzzo on 29/10/21.
//

import Foundation

struct Constants {
    
    // TestValidityCheck
    static let rapidStartHoursKey = "rapid_test_start_hours"
    static let rapidEndHoursKey = "rapid_test_end_hours"
    static let molecularStartHoursKey = "molecular_test_start_hours"
    static let molecularEndHoursKey = "molecular_test_end_hours"
    
    // VaccineValidityCheck
    static let vaccineIncompleteStartDays = "vaccine_start_day_not_complete"
    static let vaccineIncompleteEndDays = "vaccine_end_day_not_complete"
    static let vaccineCompleteStartDays = "vaccine_start_day_complete"
    static let vaccineCompleteEndDays = "vaccine_end_day_complete"

    static let vaccineCompleteStartDays_IT = "vaccine_start_day_complete_IT"
    static let vaccineCompleteEndDays_IT = "vaccine_end_day_complete_IT"
    static let vaccineCompleteStartDays_NOT_IT = "vaccine_start_day_complete_NOT_IT"
    static let vaccineCompleteEndDays_NOT_IT = "vaccine_end_day_complete_NOT_IT"
    static let vaccineBoosterStartDays_IT = "vaccine_start_day_booster_IT"
    static let vaccineBoosterEndDays_IT = "vaccine_end_day_booster_IT"
    static let vaccineBoosterStartDays_NOT_IT = "vaccine_start_day_booster_NOT_IT"
    static let vaccineBoosterEndDays_NOT_IT = "vaccine_end_day_booster_NOT_IT"
    
    // EMA settings
    static let vaccineCompleteEndDays_EMA = "vaccine_end_day_complete_EMA"
    static let vaccineCompleteExtendedDays_EMA = "vaccine_end_day_complete_extended_EMA"
    static let vaccineBoosterEndDays_EMA = "vaccine_end_day_booster_EMA"
    static let vaccineBoosterExtendedDays_EMA = "vaccine_end_day_booster_extended_EMA"
    
    static let vaccineSchoolEndDays = "vaccine_end_day_school"
    
    static let JeJVacineCode = "EU/1/20/1525"
    static let SputnikVacineCode = "Sputnik-V"
    static let sanMarinoCode = "SM"
    
    // RecoveryValidityCheck
    static let recoveryStartDays = "recovery_cert_start_day"
    static let recoveryEndDays = "recovery_cert_end_day"
    static let recoveryStartDays_IT = "recovery_cert_start_day_IT"
    static let recoveryEndDays_IT = "recovery_cert_end_day_IT"
    static let recoveryStartDays_NOT_IT = "recovery_cert_start_day_NOT_IT"
    static let recoveryEndDays_NOT_IT = "recovery_cert_end_day_NOT_IT"
    static let recoverySpecialStartDays = "recovery_pv_cert_start_day"
    static let recoverySpecialEndDays = "recovery_pv_cert_end_day"
    static let recoverySchoolEndDays = "recovery_cert_end_day_school"
    static let OID_RECOVERY = "1.3.6.1.4.1.1847.2021.1.3"
    static let OID_RECOVERY_ALT = "1.3.6.1.4.1.0.1847.2021.1.3"
    static let ItalyCountryCode = "IT"
    
    // SwitchScanMode
    static let scanMode2G = "scanMode2G"
    static let scanMode3G = "scanMode3G"
    static let scanModeBooster = "scanModeBooster"
    static let scanModeSchool = "scanModeSchool"
    static let scanMode50 = "scanMode50"
    static let scanModeItalyEntry = "scanModeItalyEntry"
    
    // Settings
    static let drlMaxRetries = "MAX_RETRY"
    
    static let boosterMinimumDosesNumber = 3
    static let jjBoosterMinimumDosesNumber = 2
}

//
//  ScanMode.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 01/02/22.
//

import Foundation


enum ScanMode: String, CaseIterable {
    case base = "scanMode3G"
    case reinforced = "scanMode2G"
    case booster = "scanModeBooster"
    case work = "scanMode50"
	case italyEntry = "scanModeItalyEntry"
	case school = "scanModeSchool"
}


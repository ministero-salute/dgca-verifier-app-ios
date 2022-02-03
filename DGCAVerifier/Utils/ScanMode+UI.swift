//
//  ScanMode+UI.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 03/02/22.
//

import Foundation

extension ScanMode {
    
    var pickerOptionName: String {
        switch self {
        case .base:
            return "home.scan.picker.mode.3G".localized
        case .reinforced:
            return "home.scan.picker.mode.2G".localized
        case .booster:
            return "home.scan.picker.mode.Booster".localized
        case .school:
            return "home.scan.picker.mode.School".localized
        case .work:
            return "home.scan.picker.mode.50".localized
        }
    }
    
    var buttonTitleBoldName: String {
        switch self {
        case .base:
            return "home.scan.button.bold.3G".localized
        case .reinforced:
            return "home.scan.button.bold.2G".localized
        case .booster:
            return "home.scan.button.bold.Booster".localized
        case .school:
            return "home.scan.button.bold.School".localized
        case .work:
            return "home.scan.button.bold.50".localized
        }
    }
    
    var buttonTitleName: String {
        switch self {
        case .base:
            return "home.scan.button.mode.3G".localized
        case .reinforced:
            return "home.scan.button.mode.2G".localized
        case .booster:
            return "home.scan.button.mode.Booster".localized
        case .school:
            return "home.scan.button.mode.School".localized
        case .work:
            return "home.scan.button.mode.50".localized
        }
    }
    
}

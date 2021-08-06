//
//  ButtonStyle.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 26/07/21.
//

import UIKit

public enum ButtonStyle {
    case blue
    case clear
    case white
    case minimal
    
    var backgroundColor: UIColor {
        switch self {
        case .blue:     return Palette.blue
        case .clear:    return Palette.white.withAlphaComponent(0)
        case .white:    return Palette.white
        case .minimal:  return Palette.white.withAlphaComponent(0)
        }
    }
    
    var tintColor: UIColor {
        switch self {
        case .blue:     return Palette.white
        case .clear:    return Palette.blue
        case .white:    return Palette.blue
        case .minimal:  return Palette.blue
        }
    }
    
    var hasBorder: Bool {
        switch self {
        case .blue:     return false
        case .clear:    return true
        case .white:    return true
        case .minimal:  return false
        }
    }
    
}

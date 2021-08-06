//
//  Font.swift
//  Verifier
//
//  Created by Andrea Prosseda on 29/07/21.
//

import Foundation
import UIKit

struct Font {
    
    static let FONT = "TitilliumWeb"
    
    enum Style {
        case bold
        case semiBold
        case regular
        case light
        
        var font: String {
            switch self {
            case .bold:     return FONT + "-Bold"
            case .semiBold: return FONT + "-SemiBold"
            case .regular:  return FONT + "-Regular"
            case .light:    return FONT + "-Light"
            }
        }
        
        var isBold: Bool {
            switch self {
            case .bold:     return true
            case .semiBold: return true
            default:        return false
            }
        }
    }
    
    static func getFont(size: CGFloat, style: Style = .regular) -> UIFont {
        let size = size * getScaleFactor(size)
        return getCustomFont(size, style) ?? getSystemFont(size, style)
    }
        
    private static func getCustomFont(_ size: CGFloat, _ style: Style) -> UIFont? {
        return UIFont(name: style.font, size: size)
    }
    
    private static func getSystemFont(_ size: CGFloat, _ style: Style) -> UIFont {
        return style.isBold ?
            UIFont.boldSystemFont(ofSize: size) :
            UIFont.systemFont(ofSize: size)
    }
    
    static var scaleFactor: CGFloat { getScaleFactor() }
    
    private static func getScaleFactor(_ size: CGFloat = 12) -> CGFloat {
        guard UIScreen.main.bounds.width < 375.0 else { return 1 }
        if (size > 20) { return 0.8 }
        return 0.85
    }
}

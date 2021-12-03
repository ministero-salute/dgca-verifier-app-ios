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
    case disabled
    
    var backgroundColor: UIColor {
        switch self {
        case .blue:     return Palette.blue
        case .clear:    return Palette.white.withAlphaComponent(0)
        case .white:    return Palette.white
        case .minimal:  return Palette.white.withAlphaComponent(0)
        case .disabled: return Palette.blackLight
        }
    }
    
    var tintColor: UIColor {
        switch self {
        case .blue:     return Palette.white
        case .clear:    return Palette.blue
        case .white:    return Palette.blue
        case .minimal:  return Palette.blue
        case .disabled: return Palette.grayDark
        }
    }
    
    var hasBorder: Bool {
        switch self {
        case .blue:     return false
        case .clear:    return true
        case .white:    return true
        case .minimal:  return false
        case .disabled: return false
        }
    }
    
}

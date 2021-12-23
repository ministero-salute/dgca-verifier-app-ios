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
//  Store.swift
//  Verifier
//
//  Created by Andrea Prosseda on 13/10/21.
//

import Foundation

public class Store {

    public enum Key: String {
        case isTorchActive
        case isFrontCameraActive
        case isTotemModeActive
        case scanMode
        case isScanModeSet
    }
    
    public static func getBool(key: Key) -> Bool {
        return userDefaults.bool(forKey: key.rawValue)
    }
    
    public static func get(key: Key) -> String? {
        return userDefaults.string(forKey: key.rawValue)
    }
    
    public static func getListString(key: Key) -> [String]? {
        return userDefaults.object(forKey: key.rawValue) as? [String]
    }
    
    public static func set(_ value: Bool, for key: Key) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    public static func set(_ value: String, for key: Key) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    public static func set(_ value: [String], for key: Key) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    public static func remove(key: Key) {
        userDefaults.removeObject(forKey: key.rawValue)
    }
    
    public static func synchronize() -> Bool {
        userDefaults.synchronize()
    }

}

extension Store {
    
    static var userDefaults: UserDefaults { UserDefaults.standard }
    
}

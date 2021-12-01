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
        case isScanMode2G
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

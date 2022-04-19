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
//  DRLDataStorage.swift
//  Verifier
//
//  Created by Andrea Prosseda on 25/08/21.
//

import Foundation
import RealmSwift
import SwiftDGC
import SwiftyJSON

struct DRLDataStorage: Codable {

    static var shared = DRLDataStorage()
    static let storage = SecureStorage<DRLDataStorage>(fileName: "drl_secure")

    var progress: DRLProgress?
    var lastFetchRaw: Date?
    
    var isDRLDownloadCompletedIT: Bool {
        if let currentVersion = progress?.currentVersion, let requestedVersion = progress?.requestedVersion, let currentChunk = progress?.currentChunk, let totalChunk = progress?.totalChunk {
            return currentVersion == requestedVersion && currentChunk == totalChunk
        }
        return true
    }
    
    var isDRLDownloadCompleted: Bool {
        return isDRLDownloadCompletedIT && isDRLDownloadCompletedEU
    }
    
    var lastFetch: Date
    {
        get { lastFetchRaw ?? .init(timeIntervalSince1970: 0) }
        set { lastFetchRaw = newValue }
    }

    public mutating func saveProgress(_ drlProgress: DRLProgress?) {
        progress = drlProgress
        save()
    }
    
    // EU STUFFS
    
    var progressEU: DRLProgress?
    var lastFetchRawEU: Date?
    
    var isDRLDownloadCompletedEU: Bool {
        if let currentVersion = progressEU?.currentVersion, let requestedVersion = progressEU?.requestedVersion, let currentChunk = progressEU?.currentChunk, let totalChunk = progressEU?.totalChunk {
            return currentVersion == requestedVersion && currentChunk == totalChunk
        }
        return true
    }
    
    var lastFetchEU: Date
    {
        get { lastFetchRawEU ?? .init(timeIntervalSince1970: 0) }
        set { lastFetchRawEU = newValue }
    }

    public mutating func saveProgressEU(_ drlProgress: DRLProgress?) {
        progressEU = drlProgress
        save()
    }
    
}

// REALM I/O
extension DRLDataStorage {
    
    private static var realm: Realm { try! Realm() }
    
    public static func store(drl: DRL, isEUDCC: Bool) {
        let startTime = Log.start(key: "[DRL] [STORAGE]")
        if (drl.isSnapshot) { storeSnapshot(drl, isEUDCC: isEUDCC) }
        if (drl.isDelta)    { storeDelta(drl, isEUDCC: isEUDCC) }
        Log.end(key: "[DRL] [STORAGE]", startTime: startTime)
    }
    
    private static func storeSnapshot(_ drl: DRL, isEUDCC: Bool) {
        if (isFirstChunk(drl)) { isEUDCC ? clearEU() : clearIT() }
        addAll(hashes: drl.revokedUcvi, isEUDCC: isEUDCC)
    }
    
    private static func storeDelta(_ drl: DRL, isEUDCC: Bool) {
        addAll(hashes: drl.delta?.insertions, isEUDCC: isEUDCC)
        removeAll(hashes: drl.delta?.deletions, isEUDCC: isEUDCC)
    }
    
    public static func addAll(hashes: [String]?, isEUDCC: Bool) {
        let storage = realm
        let dcc = hashes?.map {
            return isEUDCC ? EURevokedDCC(hash: $0) : RevokedDCC(hash: $0)
        } ?? []
        guard !dcc.isEmpty else { return }
        try! storage.write { storage.add(dcc, update: .all) }
    }
    
    public static func removeAll(hashes: [String]?, isEUDCC: Bool) {
        let storage = realm
        guard let hashes = hashes else {return}
        let objectsToDelete = storage
            .objects(isEUDCC ? EURevokedDCC.self : RevokedDCC.self)
            .filter("hashedUVCI IN %@", hashes)
        try! storage.write { storage.delete(objectsToDelete) }
    }
    
    public static func containsIT(hash: String) -> Bool {
        let storage = realm
        return storage
            .objects(RevokedDCC.self)
            .filter("hashedUVCI == %@", hash)
            .first != nil
    }
    
    public static func containsEU(hash: String) -> Bool {
        let storage = realm
        return storage
            .objects(EURevokedDCC.self)
            .filter("hashedUVCI == %@", hash)
            .first != nil
    }
    
    public static func contains(hash: String) -> Bool {
        return containsIT(hash: hash) || containsEU(hash: hash)
    }
    
    public static func drlTotalNumberIT() -> Int {
        let storage = realm
        return storage
            .objects(RevokedDCC.self)
            .count
    }
    
    public static func drlTotalNumberEU() -> Int {
        let storage = realm
        return storage
            .objects(EURevokedDCC.self)
            .count
    }
    
    public static func drlTotalNumber() -> Int {
        return drlTotalNumberIT() + drlTotalNumberEU()
    }
    
    public static func clearAll() {
        let storage = realm
        try! storage.write { storage.deleteAll() }
    }
    
    public static func clearEU() {
        let storage = realm
        try! storage.write {
            let obj = storage.objects(EURevokedDCC.self)
            realm.delete(obj)
        }
    }
    
    public static func clearIT() {
        let storage = realm
        try! storage.write {
            let obj = storage.objects(RevokedDCC.self)
            realm.delete(obj)
        }
    }
    
    public static func add(hash: String, on storage: Realm, isEUDCC: Bool) {
        let dcc = isEUDCC ? EURevokedDCC(hash: hash) : RevokedDCC(hash: hash)
        try! storage.write { storage.add(dcc) }
    }
    
    public static func remove(hash: String, on storage: Realm, isEUDCC: Bool) {
        let dcc = isEUDCC ? EURevokedDCC(hash: hash) : RevokedDCC(hash: hash)
        try! storage.write { storage.delete(dcc) }
    }
    
    private static func isFirstChunk(_ drl: DRL) -> Bool {
        drl.chunk == DRLProgress.FIRST_CHUNK
    }

}

// Persistence
extension DRLDataStorage {
    
    public func save() { Self.storage.save(self, completion: {_ in }) }
    
    static func initialize(completion: @escaping () -> Void) {
        storage.loadOverride(fallback: DRLDataStorage.shared) { success in
            guard let result = success else { return }
            DRLDataStorage.shared = result
            completion()
        }
    }
}

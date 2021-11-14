//
//  CRLDataStorage.swift
//  Verifier
//
//  Created by Andrea Prosseda on 25/08/21.
//

import Foundation
import RealmSwift
import SwiftDGC
import SwiftyJSON

struct CRLDataStorage: Codable {

    static var shared = CRLDataStorage()
    static let storage = SecureStorage<CRLDataStorage>(fileName: "crl_secure")

    var progress: CRLProgress?
    var lastFetchRaw: Date?
    
    var isCRLDownloadCompleted: Bool {
        if let currentVersion = progress?.currentVersion, let requestedVersion = progress?.requestedVersion, let currentChunk = progress?.currentChunk, let totalChunk = progress?.totalChunk {
            return currentVersion == requestedVersion && currentChunk == totalChunk
        }
        return true
    }
    
    var lastFetch: Date
    {
        get { lastFetchRaw ?? .init(timeIntervalSince1970: 0) }
        set { lastFetchRaw = newValue }
    }

    public mutating func saveProgress(_ crlProgress: CRLProgress?) {
        progress = crlProgress
        save()
    }
    
}

// REALM I/O
extension CRLDataStorage {
    
    private static var realm: Realm { try! Realm() }
    
    public static func store(crl: CRL) {
        let startTime = Log.start(key: "[CRL] [STORAGE]")
        if (crl.isSnapshot) { storeSnapshot(crl) }
        if (crl.isDelta)    { storeDelta(crl) }
        Log.end(key: "[CRL] [STORAGE]", startTime: startTime)
    }
    
    private static func storeSnapshot(_ crl: CRL) {
        if (isFirstChunk(crl)) { clear() }
        addAll(hashes: crl.revokedUcvi)
    }
    
    private static func storeDelta(_ crl: CRL) {
        addAll(hashes: crl.delta?.insertions)
        removeAll(hashes: crl.delta?.deletions)
    }
    
    public static func addAll(hashes: [String]?) {
        let storage = realm
        let dcc = hashes?.map { RevokedDCC(hash: $0) } ?? []
        guard !dcc.isEmpty else { return }
        try! storage.write { storage.add(dcc, update: .all) }
    }
    
    public static func removeAll(hashes: [String]?) {
        let storage = realm
        guard let hashes = hashes else {return}
        let objectsToDelete = storage.objects(RevokedDCC.self).filter("hashedUVCI IN %@", hashes)
        try! storage.write { storage.delete(objectsToDelete) }
    }
    
    public static func contains(hash: String) -> Bool {
        let storage = realm
        return storage
            .objects(RevokedDCC.self)
            .filter("hashedUVCI == %@", hash)
            .first != nil
    }
    
    public static func crlTotalNumber() -> Int {
        let storage = realm
        return storage
            .objects(RevokedDCC.self)
            .count
    }
    
    public static func clear() {
        let storage = realm
        try! storage.write { storage.deleteAll() }
    }
    
    public static func add(hash: String, on storage: Realm) {
        let dcc = RevokedDCC(hash: hash)
        try! storage.write { storage.add(dcc) }
    }
    
    public static func remove(hash: String, on storage: Realm) {
        let dcc = RevokedDCC(hash: hash)
        try! storage.write { storage.delete(dcc) }
    }
    
    private static func isFirstChunk(_ crl: CRL) -> Bool {
        crl.chunk == CRLProgress.FIRST_CHUNK
    }

}

// Persistence
extension CRLDataStorage {
    
    public func save() { Self.storage.save(self) }
    
    static func initialize(completion: @escaping () -> Void) {
        storage.loadOverride(fallback: CRLDataStorage.shared) { success in
            guard let result = success else { return }
            CRLDataStorage.shared = result
            completion()
        }
    }
}

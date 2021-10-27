//
//  CRLProgress.swift
//  Verifier
//
//  Created by Andrea Prosseda on 07/09/21.
//

import Foundation

struct CRLProgress: Codable {
    var currentVersion: Int
    var requestedVersion: Int
    var currentChunk: Int?
    var totalChunks: Int?
    var chunkSize: Int?
    var responseSize: Double?
    var downloadedSize: Double?
    
    static let FIRST_VERSION: Int = 0
    static let FIRST_CHUNK: Int = 1
    
    public init(version: Int? = nil) {
        currentVersion = version ?? CRLProgress.FIRST_VERSION
        requestedVersion = version ?? CRLProgress.FIRST_VERSION
    }
    
    init(serverStatus: CRLStatus?) {
        self.init(
            currentVersion: serverStatus?.fromVersion,
            requestedVersion: serverStatus?.version,
            currentChunk: CRLProgress.FIRST_CHUNK,
            totalChunks: serverStatus?.lastChunk,
            chunkSize: serverStatus?.chunkSize,
            responseSize: serverStatus?.responseSize
        )
    }
    
    public init(
        currentVersion: Int?,
        requestedVersion: Int?,
        currentChunk: Int? = nil,
        totalChunks: Int? = nil,
        chunkSize: Int? = nil,
        responseSize: Double? = nil,
        downloadedSize: Double? = nil
    ) {
        self.currentVersion = currentVersion ?? CRLProgress.FIRST_VERSION
        self.requestedVersion = requestedVersion ?? CRLProgress.FIRST_VERSION
        self.currentChunk = currentChunk
        self.totalChunks = totalChunks
        self.chunkSize = chunkSize
        self.responseSize = responseSize
        self.downloadedSize = downloadedSize ?? 0
    }
    
    var remainingSize: String {
        guard let responseSize = responseSize else { return "" }
        guard let downloadedSize = downloadedSize else { return "" }
        return (responseSize - downloadedSize).toMegaBytes.byteReadableValue
    }
    
    var current: Float {
        guard let currentChunk = currentChunk else { return 0 }
        guard let totalChunks = totalChunks else { return 0 }
        return Float(currentChunk)/Float(totalChunks)
    }
    
    var chunksMessage: String {
        guard let currentChunk = currentChunk else { return "" }
        guard let totalChunks = totalChunks else { return "" }
        return "crl.update.progress".localizeWith(currentChunk, totalChunks)
    }
    
    var downloadedMessage: String {
        guard let responseSize = responseSize else { return "" }
        guard let downloadedSize = downloadedSize else { return "" }
        let total = responseSize.toMegaBytes.byteReadableValue
        let downloaded = downloadedSize.toMegaBytes.byteReadableValue
        return "crl.update.progress.mb".localizeWith(downloaded, total)
    }
    
}

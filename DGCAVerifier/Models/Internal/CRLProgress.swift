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
//  DRLProgress.swift
//  Verifier
//
//  Created by Andrea Prosseda on 07/09/21.
//

import Foundation

struct DRLProgress: Codable {
    var currentVersion: Int
    var requestedVersion: Int
    var currentChunk: Int?
    var totalChunk: Int?
    var sizeSingleChunkInByte: Int?
    var totalSizeInByte: Int?
    var downloadedSize: Int?
    
    static let FIRST_VERSION: Int = 0
    static let FIRST_CHUNK: Int = 1
    
    public init(version: Int? = nil) {
        currentVersion = version ?? DRLProgress.FIRST_VERSION
        requestedVersion = version ?? DRLProgress.FIRST_VERSION
    }
    
    init(serverStatus: DRLStatus?) {
        self.init(
            currentVersion: serverStatus?.fromVersion,
            requestedVersion: serverStatus?.version,
            currentChunk: DRLProgress.FIRST_CHUNK,
            totalChunk: serverStatus?.totalChunk,
            sizeSingleChunkInByte: serverStatus?.sizeSingleChunkInByte,
            totalSizeInByte: serverStatus?.totalSizeInByte
        )
    }
    
    public init(
        currentVersion: Int?,
        requestedVersion: Int?,
        currentChunk: Int? = nil,
        totalChunk: Int? = nil,
        sizeSingleChunkInByte: Int? = nil,
        totalSizeInByte: Int? = nil,
        downloadedSize: Int? = nil
    ) {
        self.currentVersion = currentVersion ?? DRLProgress.FIRST_VERSION
        self.requestedVersion = requestedVersion ?? DRLProgress.FIRST_VERSION
        self.currentChunk = currentChunk
        self.totalChunk = totalChunk
        self.sizeSingleChunkInByte = sizeSingleChunkInByte
        self.totalSizeInByte = totalSizeInByte
        self.downloadedSize = downloadedSize ?? 0
    }
    
    var remainingBytes: Int? {
        guard let responseSize = totalSizeInByte else { return nil }
        guard let downloadedSize = downloadedSize else { return nil }
        return responseSize - downloadedSize
    }
    
    var remainingSize: String {
        guard let responseSize = totalSizeInByte else { return "" }
        guard let downloadedSize = downloadedSize else { return "" }
        return (responseSize - downloadedSize).toMegaBytes.byteReadableValue
    }
    
    var current: Float {
        guard let currentChunk = currentChunk else { return 0 }
        guard let totalChunks = totalChunk else { return 0 }
        return Float(currentChunk)/Float(totalChunks)
    }
    
    var chunksMessage: String {
        guard let currentChunk = currentChunk else { return "" }
        guard let totalChunks = totalChunk else { return "" }
        return "drl.update.progress".localizeWith(currentChunk, totalChunks)
    }
    
    var downloadedMessage: String {
        guard let responseSize = totalSizeInByte else { return "" }
        guard let downloadedSize = downloadedSize else { return "" }
        let total = responseSize.toMegaBytes.byteReadableValue
        let downloaded = downloadedSize.toMegaBytes.byteReadableValue
        return "drl.update.progress.mb".localizeWith(downloaded, total)
    }
    
    mutating func updateProgress(with size: Int?) {
        self.currentChunk = (self.currentChunk ?? DRLProgress.FIRST_CHUNK) + 1
        self.downloadedSize = (self.downloadedSize ?? 0) + (size ?? 0)
    }
    
    mutating func completeProgress() {
        self.currentVersion = self.requestedVersion
    }
    
    
}

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
    var totalChunk: Int?
    var sizeSingleChunkInByte: Int?
    var totalSizeInByte: Int?
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
        downloadedSize: Double? = nil
    ) {
        self.currentVersion = currentVersion ?? CRLProgress.FIRST_VERSION
        self.requestedVersion = requestedVersion ?? CRLProgress.FIRST_VERSION
        self.currentChunk = currentChunk
        self.totalChunk = totalChunk
        self.sizeSingleChunkInByte = sizeSingleChunkInByte
        self.totalSizeInByte = totalSizeInByte
        self.downloadedSize = downloadedSize ?? 0
    }
    
    var remainingSize: String {
        guard let responseSize = totalSizeInByte else { return "" }
        guard let downloadedSize = downloadedSize else { return "" }
        return (responseSize.doubleValue - downloadedSize).toMegaBytes.byteReadableValue
    }
    
    var current: Float {
        guard let currentChunk = currentChunk else { return 0 }
        guard let totalChunks = totalChunk else { return 0 }
        return Float(currentChunk)/Float(totalChunks)
    }
    
    var chunksMessage: String {
        guard let currentChunk = currentChunk else { return "" }
        guard let totalChunks = totalChunk else { return "" }
        return "crl.update.progress".localizeWith(currentChunk, totalChunks)
    }
    
    var downloadedMessage: String {
        guard let responseSize = totalSizeInByte else { return "" }
        guard let downloadedSize = downloadedSize else { return "" }
        let total = responseSize.toMegaBytes.byteReadableValue
        let downloaded = downloadedSize.toMegaBytes.byteReadableValue
        return "crl.update.progress.mb".localizeWith(downloaded, total)
    }
    
}

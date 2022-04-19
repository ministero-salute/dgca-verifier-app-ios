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
//  DRLTotalProgress.swift
//  Verifier
//
//  Created by Emilio Apuzzo on 21/04/22.
//

import Foundation

struct DRLTotalProgress: Codable {
    var ITProgress: DRLProgress {
        DRLITSynchronizationManager.shared.progress
    }
    var EUProgress: DRLProgress {
        DRLEUSynchronizationManager.shared.progress
    }
    
    var remainingSize: String {
        guard let responseSizeIT = ITProgress.totalSizeInByte?.doubleValue,
              let responseSizeEU = EUProgress.totalSizeInByte?.doubleValue,
              let downloadedSizeIT = ITProgress.downloadedSize,
              let downloadedSizeEU = EUProgress.downloadedSize
        else {
            return ""
        }
        let responseSize = responseSizeIT + responseSizeEU
        let downloadedSize = downloadedSizeIT + downloadedSizeEU
        return (responseSize - downloadedSize).toMegaBytes.byteReadableValue
    }
    
    var current: Float {
        let currentChunkIT = ITProgress.currentChunk ?? 0
        let totalChunksIT = ITProgress.totalChunk ?? 0
        let currentChunkEU = EUProgress.currentChunk ?? 0
        let totalChunksEU = EUProgress.totalChunk ?? 0
        return Float(currentChunkIT + currentChunkEU)/Float(totalChunksIT + totalChunksEU)
    }
    
    var chunksMessage: String {
        let currentChunkIT = ITProgress.currentChunk ?? 0
        let totalChunksIT = ITProgress.totalChunk ?? 0
        let currentChunkEU = EUProgress.currentChunk ?? 0
        let totalChunksEU = EUProgress.totalChunk ?? 0
        
        let currentChunk = currentChunkIT + currentChunkEU
        let totalChunks = totalChunksIT + totalChunksEU
        return "drl.update.progress".localizeWith(currentChunk, totalChunks)
    }
    
    var downloadedMessage: String {
        
        let responseSizeIT = ITProgress.totalSizeInByte ?? 0
        let downloadedSizeIT = ITProgress.downloadedSize ?? 0
        let responseSizeEU = EUProgress.totalSizeInByte ?? 0
        let downloadedSizeEU = EUProgress.downloadedSize ?? 0
        
        let totalIT = responseSizeIT.toMegaBytes
        let downloadedIT = downloadedSizeIT.toMegaBytes
        let totalEU = responseSizeEU.toMegaBytes
        let downloadedEU = downloadedSizeEU.toMegaBytes
        let total = totalIT + totalEU
        let downloaded = downloadedIT + downloadedEU
        return "drl.update.progress.mb".localizeWith(downloaded.byteReadableValue, total.byteReadableValue)
    }
}

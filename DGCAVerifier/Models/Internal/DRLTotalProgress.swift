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

typealias ProgressAccessor = () -> DRLProgress

struct DRLTotalProgress {
    private let progressAccessors: [ProgressAccessor]
    
    init(progressAccessors: [ProgressAccessor]) {
        self.progressAccessors = progressAccessors
    }
    
    var remainingSize: String {
       let isTotalSizeSet = self.progressAccessors
        	.map{ $0().totalSizeInByte?.doubleValue }
            .filter{ $0 == nil }
            .count < 2
        
        let isDownloadedSizeSet = self.progressAccessors
            .map{ $0().downloadedSize }
            .filter{ $0 == nil }
            .count < 2
        
        guard isTotalSizeSet && isDownloadedSizeSet else { return "" }
        
        let responseSizes = self.progressAccessors
            .map{ $0().totalSizeInByte?.doubleValue ?? 0 }
            .reduce(0, +)
        let downloadedSizes = self.progressAccessors
            .map{ $0().downloadedSize ?? 0 }
            .reduce(0, +)
        
        return (responseSizes - downloadedSizes).toMegaBytes.byteReadableValue
    }
    
    var current: Float {
        let currentChunks = self.progressAccessors
            .map{ $0().currentChunk ?? 0 }
            .reduce(0, +)
        	
        let totalChunks = self.progressAccessors
            .map{ $0().totalChunk ?? 0 }
            .reduce(0, +)

        return Float(currentChunks)/Float(totalChunks)
    }
    
    var chunksMessage: String {
        let currentChunks = self.progressAccessors
            .map{ $0().currentChunk ?? 0 }
            .reduce(0, +)
        
        let totalChunks = self.progressAccessors
            .map{ $0().totalChunk ?? 0 }
            .reduce(0, +)
        
        return "drl.update.progress".localizeWith(currentChunks, totalChunks)
    }
    
    var downloadedMessage: String {
        let responseSizes = self.progressAccessors
            .map{ $0().totalSizeInByte?.doubleValue ?? 0 }
            .reduce(0, +)
            .toMegaBytes
            .byteReadableValue
        
        let downloadedSizes = self.progressAccessors
            .map{ $0().downloadedSize ?? 0 }
            .reduce(0, +)
            .toMegaBytes
            .byteReadableValue
        
        return "drl.update.progress.mb".localizeWith(downloadedSizes, responseSizes)
    }
}

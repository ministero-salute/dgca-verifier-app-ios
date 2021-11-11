//
//  CRLStatus.swift
//  Verifier
//
//  Created by Andrea Prosseda on 07/09/21.
//

import Foundation

struct CRLStatus: Codable {
    var id: String?
    var fromVersion: Int?
    var version: Int?
    var chunk: Int?
    var totalSizeInByte: Int?
    var sizeSingleChunkInByte: Int?
    var totalChunk: Int?
    var totalNumberUCVI: Int?
}

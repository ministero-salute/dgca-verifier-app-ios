//
//  GatewayConnection+Revocation.swift
//  Verifier
//
//  Created by Andrea Prosseda on 25/08/21.
//
import Foundation
import SwiftDGC

extension GatewayConnection {

    private var revocationUrl: String { "https://storage.googleapis.com/dgc-greenpass/10K.json" }
    
    private var statusUrl: String { "https://storage.googleapis.com/dgc-greenpass/10K.json" }
    
    func revocationStatus(_ progress: CRLProgress?, completion: ((CRLStatus?, String?) -> Void)? = nil) {
        let version = progress?.currentVersion
        let chunk = progress?.currentChunk
        status(version: version, chunk: chunk) { crlStatus in
            
            guard let crlStatus = crlStatus else {
                completion?(nil, "server.error.generic.error".localized)
                return
            }
            
            completion?(crlStatus, nil)
        }
    }

    func updateRevocationList(_ progress: CRLProgress?, completion: ((CRL?, String?) -> Void)? = nil) {
        let version = progress?.currentVersion
        let chunk = progress?.currentChunk
        
        getCRL(version: version, chunk: chunk) { crl in
            
            guard let crl = crl else {
                completion?(nil, "server.error.generic.error".localized)
                return
            }
            
            completion?(self.getCRLMock(from: crl), nil)
        }
    }

    private func getCRL(version: Int?, chunk: Int?, completion: ((CRL?) -> Void)?) {
        let restStartTime = Log.start(key: "[CRL] [REST]")
        session.request(revocationUrl).response {
            Log.end(key: "[CRL] [REST]", startTime: restStartTime)
            
            let jsonStartTime = Log.start(key: "[CRL] [JSON]")
            let decoder = JSONDecoder()
            var data = try? decoder.decode(CRL.self, from: $0.data ?? .init())
            data?.responseSize = $0.data?.count.doubleValue
            Log.end(key: "[CRL] [JSON]", startTime: jsonStartTime)
            
            guard let crl = data else {
                completion?(nil)
                return
            }
            completion?(crl)
        }
    }
    
    private func getCRLDeltaMOCK(version: Int?, chunk: Int?, completion: ((CRL?) -> Void)?) {
        let restStartTime = Log.start(key: "[CRL] [REST]")
        
        var revocationUrl = revocationUrl
        //MOCK
        if version == 1 {
            if chunk == 1 {
                revocationUrl = "https://run.mocky.io/v3/7d71ba28-6ee0-4e5a-a815-93f3a33e7ec4"
            }
            else if chunk == 2 {
                revocationUrl = "https://run.mocky.io/v3/bf32eb99-1993-4272-b9cc-6522a04be009"
            }
            else if chunk == 3{
                revocationUrl = "https://run.mocky.io/v3/ec6c4335-1e2c-4917-993c-99ea992c0f4e"
            }
        }
        
        session.request(revocationUrl).response {
            Log.end(key: "[CRL] [REST]", startTime: restStartTime)
            
            let jsonStartTime = Log.start(key: "[CRL] [JSON]")
            let decoder = JSONDecoder()
            var data = try? decoder.decode(CRL.self, from: $0.data ?? .init())
            data?.responseSize = $0.data?.count.doubleValue
            Log.end(key: "[CRL] [JSON]", startTime: jsonStartTime)
            
            guard let crl = data else {
                completion?(nil)
                return
            }
            completion?(crl)
        }
    }
    
    private func status(version: Int?, chunk: Int?, completion: ((CRLStatus?) -> Void)?) {
        let restStartTime = Log.start(key: "[CRL STATUS] [REST]")
        session.request(statusUrl).response {
            Log.end(key: "[CRL STATUS] [REST]", startTime: restStartTime)
            
            let jsonStartTime = Log.start(key: "[CRL STATUS] [JSON]")
            let decoder = JSONDecoder()
            let data = try? decoder.decode(CRLStatus.self, from: $0.data ?? .init())
            Log.end(key: "[CRL STATUS] [JSON]", startTime: jsonStartTime)
            
            guard let status = data else {
                completion?(nil)
                return
            }
            
            //MOCK
//            if version == 0{
//                completion?(self.getCRLStatusMock())
//            }
//            else if version == 1 {
//                completion?(self.getCRLStatusDeltaMock())
//            }
//            else {
//                completion?(status)
//            }
            
            completion?(self.getCRLStatusMock())
        }
    }

    private func getCRLMock(from crl: CRL) -> CRL {
        var newCrl = crl
        var mockStatus = getCRLStatusMock()
        
//        MOCK
//        if crl.version == 2 {
//            mockStatus = getCRLStatusDeltaMock()
//        }
        
        newCrl.version = mockStatus.version
        newCrl.chunk = mockStatus.chunk
        newCrl.lastChunk = mockStatus.totalChunk
        newCrl.sizeSingleChunkInByte = mockStatus.sizeSingleChunkInByte
        newCrl.totalNumberUCVI = mockStatus.totalNumberUCVI
        return newCrl
    }
    
    private func getCRLStatusMock() -> CRLStatus {
        var status = CRLStatus()
        status.fromVersion = 0
        status.version = 1
        status.chunk = 1
        status.totalSizeInByte = 8388600
        status.sizeSingleChunkInByte = 838860
        status.totalChunk = 1
        status.totalNumberUCVI = 10000
        return status
    }
    
    private func getCRLStatusDeltaMock() -> CRLStatus {
        var status = CRLStatus()
        status.fromVersion = 1
        status.version = 2
        status.chunk = 1
        status.totalSizeInByte = 8388600
        status.sizeSingleChunkInByte = 838860
        status.totalChunk = 3
        status.totalNumberUCVI = 10015
        return status
    }
    
}

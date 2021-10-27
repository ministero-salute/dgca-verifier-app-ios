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
            completion?(self.getCRLStatusMock())
        }
    }

    private func getCRLMock(from crl: CRL) -> CRL {
        var crl = crl
        crl.version = getCRLStatusMock().version
        return crl
    }
    
    private func getCRLStatusMock() -> CRLStatus {
        var status = CRLStatus()
        status.fromVersion = 47
        status.version = 58
        status.lastChunk = 10
        status.chunkSize = 10000
        status.totalNumberUCVI = 1000000
        status.responseSize = (status.lastChunk?.doubleValue ?? 0.0) * 740 * 1024
        return status
    }
    
}

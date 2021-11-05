//
//  GatewayConnection+Revocation.swift
//  Verifier
//
//  Created by Andrea Prosseda on 25/08/21.
//
import Foundation
import SwiftDGC

extension GatewayConnection {

    private var revocationUrl: String { "https://testaka4.sogei.it/v1/dgc/drl?version=0&chunk=1" }
    
    private var statusUrl: String { "https://testaka4.sogei.it/v1/dgc/drl/check?version=0" }
    
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
            
            completion?(crl, nil)
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
            
            completion?(status)
        }
    }
}

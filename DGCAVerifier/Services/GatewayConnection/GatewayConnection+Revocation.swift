//
//  GatewayConnection+Revocation.swift
//  Verifier
//
//  Created by Andrea Prosseda on 25/08/21.
//
import Foundation
import SwiftDGC

extension GatewayConnection {
    
    private var revocationUrl: String { "https://testaka4.sogei.it/v1/dgc/drl" }
    
    private var statusUrl: String { "https://testaka4.sogei.it/v1/dgc/drl/check" }
    
    func revocationStatus(_ progress: CRLProgress?, completion: ((CRLStatus?, String?, Int?) -> Void)? = nil) {
        let version = progress?.currentVersion
        let chunk = progress?.currentChunk
        status(version: version, chunk: chunk) { crlStatus, statusCode in
            
            guard let crlStatus = crlStatus else {
                completion?(nil, "server.error.generic.error".localized, statusCode)
                return
            }
            
            completion?(crlStatus, nil, statusCode)
        }
    }
    
    func updateRevocationList(_ progress: CRLProgress?, completion: ((CRL?, String?, Int?) -> Void)? = nil) {
        let version = progress?.currentVersion
        let chunk = progress?.currentChunk
        
        getCRL(version: version, chunk: chunk) { crl, statusCode in
            
            guard let crl = crl else {
                completion?(nil, "server.error.generic.error".localized, statusCode)
                return
            }
            
            completion?(crl, nil, statusCode)
        }
    }
    
    private func getCRL(version: Int?, chunk: Int?, completion: ((CRL?, Int?) -> Void)?) {
        let restStartTime = Log.start(key: "[CRL] [REST]")
        let version = version ?? 0
        let chunk = chunk ?? 1
        
        session.request("\(revocationUrl)?version=\(version)&chunk=\(chunk)").response {
            //  Were the response to be `nil` (AFRequest failed, see $0.result),
            //  it'd be okay for it to be handled just like a statusCode 408.
            let responseStatusCode: Int? = $0.response?.statusCode ?? 408
            
            guard responseStatusCode == 200 else {
                Log.end(key: "[CRL] [REST]", startTime: restStartTime)
                let jsonStartTime = Log.start(key: "[CRL STATUS] [ERROR]")
                Log.end(key: "[CRL] [ERROR \(responseStatusCode?.stringValue ?? "nil")]", startTime: jsonStartTime)
                completion?(nil, responseStatusCode)
                return
            }
            
            Log.end(key: "[CRL] [REST]", startTime: restStartTime)
            
            let jsonStartTime = Log.start(key: "[CRL] [JSON]")
            let decoder = JSONDecoder()
            var data = try? decoder.decode(CRL.self, from: $0.data ?? .init())
            data?.responseSize = $0.data?.count.doubleValue
            Log.end(key: "[CRL] [JSON]", startTime: jsonStartTime)
            
            guard let crl = data else {
                completion?(nil, responseStatusCode)
                return
            }
            
            completion?(crl, responseStatusCode)
        }
    }
    
    private func status(version: Int?, chunk: Int?, completion: ((CRLStatus?, Int?) -> Void)?) {
        let restStartTime = Log.start(key: "[CRL STATUS] [REST]")
        let version = version ?? 0
        let chunk = chunk ?? 1
        
        session.request("\(statusUrl)?version=\(version)&chunk=\(chunk)").response {
            // Were the response to be `nil`, it'd okay for it to be handled just like a statusCode 400.
            let responseStatusCode: Int? = $0.response?.statusCode
            
            guard responseStatusCode == 200 else {
                Log.end(key: "[CRL] [REST]", startTime: restStartTime)
                let jsonStartTime = Log.start(key: "[CRL STATUS] [ERROR]")
                Log.end(key: "[CRL] [ERROR \(responseStatusCode?.stringValue ?? "nil")]", startTime: jsonStartTime)
                completion?(nil, responseStatusCode)
                return
            }
            
            Log.end(key: "[CRL STATUS] [REST]", startTime: restStartTime)
            
            let jsonStartTime = Log.start(key: "[CRL STATUS] [JSON]")
            let decoder = JSONDecoder()
            let data = try? decoder.decode(CRLStatus.self, from: $0.data ?? .init())
            Log.end(key: "[CRL STATUS] [JSON]", startTime: jsonStartTime)
            
            guard let status = data else {
                completion?(nil, responseStatusCode)
                return
            }
            
            completion?(status, responseStatusCode)
        }
    }
}

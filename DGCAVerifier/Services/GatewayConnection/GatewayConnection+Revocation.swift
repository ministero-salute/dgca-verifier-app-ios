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
//  GatewayConnection+Revocation.swift
//  Verifier
//
//  Created by Andrea Prosseda on 25/08/21.
//
import Foundation
import SwiftDGC

extension GatewayConnection {
    
    private var revocationUrl: String { baseUrl + "drl" }
    
    private var statusUrl: String { baseUrl + "drl/check" }
    
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
        let versionString: Int = version ?? 0
        let chunkString: Int = chunk ?? 1
        
        session.request("\(revocationUrl)?version=\(versionString)&chunk=\(chunkString)").response {
            //  Were the response to be `nil` (AFRequest failed, see $0.result),
            //  it'd be okay for it to be handled just like a statusCode 408.
            let responseStatusCode = $0.response?.statusCode ?? 408
            
            guard responseStatusCode == 200, $0.error == nil else {
                Log.end(key: "[CRL] [REST]", startTime: restStartTime)
                let jsonStartTime = Log.start(key: "[CRL STATUS] [ERROR]")
                Log.end(key: "[CRL] [ERROR \(responseStatusCode.stringValue)]", startTime: jsonStartTime)
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
        let versionString: Int = version ?? 0
        let chunkString: Int = chunk ?? 1
        
        session.request("\(statusUrl)?version=\(versionString)&chunk=\(chunkString)").response {
            // Were the response to be `nil`, it'd okay for it to be handled just like a statusCode 400.
            let responseStatusCode = $0.response?.statusCode ?? 408
            
            guard responseStatusCode == 200 else {
                Log.end(key: "[CRL] [REST]", startTime: restStartTime)
                let jsonStartTime = Log.start(key: "[CRL STATUS] [ERROR]")
                Log.end(key: "[CRL] [ERROR \(responseStatusCode.stringValue)]", startTime: jsonStartTime)
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

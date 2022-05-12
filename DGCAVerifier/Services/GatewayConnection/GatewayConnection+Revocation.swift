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
    
    private var itRevocationURL: String { self.baseUrl + "drl" }
    private var itStatusURL: String { self.baseUrl + "drl/check" }
    private var euRevocationURL: String { self.baseUrl + "eu/drl" }
    private var euStatusURL: String { self.baseUrl + "eu/drl/check" }
    
    func revocationStatus(managerType: SyncManagerType, _ progress: DRLProgress?, completion: ((DRLStatus?, String?, Int?) -> Void)? = nil) {
        let version = progress?.currentVersion
        let chunk = progress?.currentChunk
        status(managerType: managerType, version: version, chunk: chunk) { drlStatus, statusCode in
            
            guard let drlStatus = drlStatus else {
                completion?(nil, "server.error.generic.error".localized, statusCode)
                return
            }
            
            completion?(drlStatus, nil, statusCode)
        }
    }
    
    func updateRevocationList(managerType: SyncManagerType, _ progress: DRLProgress?, completion: ((DRL?, String?, Int?) -> Void)? = nil) {
        let version = progress?.currentVersion
        let chunk = progress?.currentChunk
        
        getDRL(managerType: managerType, version: version, chunk: chunk) { drl, statusCode in
            
            guard let drl = drl else {
                completion?(nil, "server.error.generic.error".localized, statusCode)
                return
            }
            
            completion?(drl, nil, statusCode)
        }
    }
    
    private func getDRL(managerType: SyncManagerType, version: Int?, chunk: Int?, completion: ((DRL?, Int?) -> Void)?) {
        
        let identity: String = "[DRL - \(managerType)]"
        
        let versionString: Int = version ?? 0
        let chunkString: Int = chunk ?? 1
        let drlURL: String = managerType == .IT ? itRevocationURL : euRevocationURL
        
        let restStartTime = Log.start(key: "\(identity) [REST]")
        
        session.request("\(drlURL)?version=\(versionString)&chunk=\(chunkString)").response {
            //  Were the response to be `nil` (AFRequest failed, see $0.result),
            //  it'd be okay for it to be handled just like a statusCode 408.
            let responseStatusCode = $0.response?.statusCode ?? 408
            
            guard responseStatusCode == 200, $0.error == nil else {
                Log.end(key: "\(identity) [REST]", startTime: restStartTime)
                let jsonStartTime = Log.start(key: "\(identity) [DRL] [ERROR]")
                Log.end(key: "\(identity) [ERROR \(responseStatusCode.stringValue)]", startTime: jsonStartTime)
                completion?(nil, responseStatusCode)
                return
            }
            
            Log.end(key: "\(identity) [REST]", startTime: restStartTime)
            
            let jsonStartTime = Log.start(key: "\(identity) [JSON]")
            let decoder = JSONDecoder()
            var data = try? decoder.decode(DRL.self, from: $0.data ?? .init())
            data?.responseSize = $0.data?.count.doubleValue
            Log.end(key: "\(identity) [JSON]", startTime: jsonStartTime)
            
            guard let drl = data else {
                completion?(nil, responseStatusCode)
                return
            }
            
            completion?(drl, responseStatusCode)
        }
    }
    
    private func status(managerType: SyncManagerType, version: Int?, chunk: Int?, completion: ((DRLStatus?, Int?) -> Void)?) {
        let identity: String = "[DRL - \(managerType)]"

        let restStartTime = Log.start(key: "\(identity) [STATUS] [REST]")
        let versionString: Int = version ?? 0
        let chunkString: Int = chunk ?? 1
        
        let statusURL: String = managerType == .IT ? itStatusURL : euStatusURL
        
        session.request("\(statusURL)?version=\(versionString)&chunk=\(chunkString)").response {
            // Were the response to be `nil`, it'd okay for it to be handled just like a statusCode 400.
            let responseStatusCode = $0.response?.statusCode ?? 408
            
            guard responseStatusCode == 200 else {
                Log.end(key: "\(identity) [REST]", startTime: restStartTime)
                let jsonStartTime = Log.start(key: "\(identity) [STATUS] [ERROR]")
                Log.end(key: "\(identity) [ERROR \(responseStatusCode.stringValue)]", startTime: jsonStartTime)
                completion?(nil, responseStatusCode)
                return
            }
            
            Log.end(key: "\(identity) [STATUS] [REST]", startTime: restStartTime)
            
            let jsonStartTime = Log.start(key: "\(identity) [STATUS] [JSON]")
            let decoder = JSONDecoder()
            let data = try? decoder.decode(DRLStatus.self, from: $0.data ?? .init())
            Log.end(key: "\(identity) [STATUS] [JSON]", startTime: jsonStartTime)
            
            guard let status = data else {
                completion?(nil, responseStatusCode)
                return
            }
            
            completion?(status, responseStatusCode)
        }
    }
}

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
import RxSwift
import Alamofire

extension GatewayConnection {
    
    private var revocationUrl: String { baseUrl + "drl" }
    
    private var statusUrl: String { baseUrl + "drl/check" }
    
    func _revocationStatus(_ progress: DRLProgress) -> RxSwift.Observable<DRLStatus> {
        let version = progress.currentVersion
        let chunk = progress.currentChunk ?? 1
        let url = "\(self.statusUrl)?version=\(version)&chunk=\(chunk)"
        return self.get(url: url)
    }
    
    func getDLRChunk(_ progress: DRLProgress) -> RxSwift.Observable<DRL> {
        let version = progress.currentVersion
        let chunk = progress.currentChunk ?? 1
        let url = "\(revocationUrl)?version=\(version)&chunk=\(chunk)"
        return self.get(url: url)
    }
    
    
    func revocationStatus(_ progress: DRLProgress?, completion: ((DRLStatus?, String?, Int?) -> Void)? = nil) {
        let version = progress?.currentVersion
        let chunk = progress?.currentChunk
        status(version: version, chunk: chunk) { drlStatus, statusCode in
            
            guard let drlStatus = drlStatus else {
                completion?(nil, "server.error.generic.error".localized, statusCode)
                return
            }
            
            completion?(drlStatus, nil, statusCode)
        }
    }
    
    func updateRevocationList(_ progress: DRLProgress?, completion: ((DRL?, String?, Int?) -> Void)? = nil) {
        let version = progress?.currentVersion
        let chunk = progress?.currentChunk
        
        getDRL(version: version, chunk: chunk) { drl, statusCode in
            
            guard let drl = drl else {
                completion?(nil, "server.error.generic.error".localized, statusCode)
                return
            }
            
            completion?(drl, nil, statusCode)
        }
    }
    
    
    private func getDRL(version: Int?, chunk: Int?, completion: ((DRL?, Int?) -> Void)?) {
        let restStartTime = Log.start(key: "[DRL] [REST]")
        let versionString: Int = version ?? 0
        let chunkString: Int = chunk ?? 1
        
        session.request("\(revocationUrl)?version=\(versionString)&chunk=\(chunkString)").response {
            //  Were the response to be `nil` (AFRequest failed, see $0.result),
            //  it'd be okay for it to be handled just like a statusCode 408.
            let headers = $0.response?.headers.dictionary.map{ "\($0.key) : \($0.value) \n" }.reduce("", +) ?? ""
            print("Headers: \n \(headers)")
            
            let responseStatusCode = $0.response?.statusCode ?? 408
            
            guard responseStatusCode == 200 else {
                Log.end(key: "[DRL] [REST]", startTime: restStartTime)
                let jsonStartTime = Log.start(key: "[DRL STATUS] [ERROR]")
                Log.end(key: "[DRL] [ERROR \(responseStatusCode.stringValue)]", startTime: jsonStartTime)
                completion?(nil, responseStatusCode)
                return
            }
            
            Log.end(key: "[DRL] [REST]", startTime: restStartTime)
            
            let jsonStartTime = Log.start(key: "[DRL] [JSON]")
            let decoder = JSONDecoder()
            var data = try? decoder.decode(DRL.self, from: $0.data ?? .init())
            data?.responseSize = $0.data?.count.doubleValue
            Log.end(key: "[DRL] [JSON]", startTime: jsonStartTime)
            
            guard let drl = data else {
                completion?(nil, responseStatusCode)
                return
            }
            
            completion?(drl, responseStatusCode)
        }
    }
    
    private func status(version: Int?, chunk: Int?, completion: ((DRLStatus?, Int?) -> Void)?) {
        let restStartTime = Log.start(key: "[DRL STATUS] [REST]")
        let versionString: Int = version ?? 0
        let chunkString: Int = chunk ?? 1
        
        session.request("\(statusUrl)?version=\(versionString)&chunk=\(chunkString)").response {
            // Were the response to be `nil`, it'd okay for it to be handled just like a statusCode 400.
            let responseStatusCode = $0.response?.statusCode ?? 408
            
            guard responseStatusCode == 200 else {
                Log.end(key: "[DRL] [REST]", startTime: restStartTime)
                let jsonStartTime = Log.start(key: "[DRL STATUS] [ERROR]")
                Log.end(key: "[DRL] [ERROR \(responseStatusCode.stringValue)]", startTime: jsonStartTime)
                completion?(nil, responseStatusCode)
                return
            }
            
            Log.end(key: "[DRL STATUS] [REST]", startTime: restStartTime)
            
            let jsonStartTime = Log.start(key: "[DRL STATUS] [JSON]")
            let decoder = JSONDecoder()
            let data = try? decoder.decode(DRLStatus.self, from: $0.data ?? .init())
            Log.end(key: "[DRL STATUS] [JSON]", startTime: jsonStartTime)
            
            guard let status = data else {
                completion?(nil, responseStatusCode)
                return
            }
            
            completion?(status, responseStatusCode)
        }
    }
}

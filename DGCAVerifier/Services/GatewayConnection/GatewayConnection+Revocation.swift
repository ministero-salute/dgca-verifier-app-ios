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
    
    func getDRLStatus(_ progress: DRLProgress) -> RxSwift.Observable<DRLStatus> {
        let version = progress.currentVersion
        let chunk = progress.currentChunk ?? 1
        let url = "\(self.statusUrl)?version=\(version)&chunk=\(chunk)"
        return self.get(url: url)
    }

    func getDRLChunk(version: Int, chunk: Int) -> RxSwift.Observable<DRL> {
        let url = "\(self.revocationUrl)?version=\(version)&chunk=\(chunk)"
        return self.get(url: url)
    }
    
}

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
//  CustomHeaderInterceptor.swift
//  Verifier
//
//  Created by Davide Aliti on 14/03/22.
//

import Foundation
import Alamofire

struct CustomHeaderInterceptor: RequestInterceptor {
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        let iosVersion = ProcessInfo.processInfo.operatingSystemVersionString
        let formattedIOSVersion = iosVersion.replacingOccurrences(of: "Version ", with: "").replacingOccurrences(of: " (Build ", with: "; Build/")
        let customHeader = HTTPHeader(name: "User-Agent", value: "DGCAVerifierIOS / \(appVersion ?? "") (iOS \(formattedIOSVersion)")
        urlRequest.headers.add(customHeader)
        completion(.success(urlRequest))
    }
}

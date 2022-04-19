//
/*-
 * ---license-start
 * eu-digital-green-certificates / dgca-verifier-app-ios
 * ---
 * Copyright (C) 2021 T-Systems International GmbH and all other contributors
 * ---
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ---license-end
 */
//  
//  GatewayConnection.swift
//  DGCAVerifier
//  
//  Created by Yannick Spreen on 4/24/21.
//  

import Foundation
import Alamofire
import SwiftDGC
import SwiftyJSON

extension Bundle {
    func infoForKey(_ key: String) -> String? {
        return (Bundle.main.infoDictionary?[key] as? String)?.replacingOccurrences(of: "\\", with: "")
    }
}

class GatewayConnection {
    
    let baseUrl: String
    let session: Session
    var timer: Timer?
    
    private let certificateFilename: String
    private let secondCertificateFilename: String
    private let certificateEvaluator: String
    
    static let shared = GatewayConnection()
    
    private init() {
        baseUrl = Bundle.main.infoForKey("baseUrl")!
        certificateFilename = Bundle.main.infoForKey("certificateFilename")!
        secondCertificateFilename = Bundle.main.infoForKey("secondCertificateFilename")!
        certificateEvaluator = Bundle.main.infoForKey("certificateEvaluator")!
        
        // Init certificate for pinning
        let filePath = Bundle.main.path(forResource: certificateFilename, ofType: nil)!
        let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
        let certificate = SecCertificateCreateWithData(nil, data as CFData)!
        
        // Init certificate for pinning
        let secondFilePath = Bundle.main.path(forResource: secondCertificateFilename, ofType: nil)!
        let secondData = try! Data(contentsOf: URL(fileURLWithPath: secondFilePath))
        let secondCertificate = SecCertificateCreateWithData(nil, secondData as CFData)!
                    
        // Init session
        let evaluators = [certificateEvaluator: PinnedCertificatesTrustEvaluator(certificates: [certificate, secondCertificate])]
        session = Session(interceptor: CustomHeaderInterceptor(), serverTrustManager: ServerTrustManager(evaluators: evaluators))
    }
    
    func initialize(completion: (()->())? = nil) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            self.trigger(completion: completion)
        }
        timer?.tolerance = 5.0
        self.trigger(completion: completion)
    }
    
    func trigger(completion: (()->())? = nil) {
        guard LocalData.sharedInstance.lastFetch.timeIntervalSinceNow < -24 * 60 * 60 else {
            return
        }
        completion?()
    }

}

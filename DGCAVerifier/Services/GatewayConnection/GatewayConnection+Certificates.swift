//
//  GatewayConnection+Certificates.swift
//  Verifier
//
//  Created by Andrea Prosseda on 27/07/21.
//

import Foundation
import Alamofire
import SwiftDGC
import SwiftyJSON

extension GatewayConnection {
    
    private var certUpdateUrl: String { baseUrl + "signercertificate/update" }
    private var certStatusUrl: String { baseUrl + "signercertificate/status" }

    func update(completion: ((String?) -> Void)? = nil) {
        certUpdate(resume: LocalData.sharedInstance.resumeToken) { [weak self] encodedCert, token, error in
            
            if error != nil {
                completion?(error)
                return
            }
            
            guard let encodedCert = encodedCert else {
                self?.status(completion: completion)
                return
            }
            LocalData.sharedInstance.add(encodedPublicKey: encodedCert)
            LocalData.sharedInstance.resumeToken = token
            self?.update(completion: completion)
        }
    }
    
    private func certUpdate(resume resumeToken: String? = nil, completion: ((String?, String?, String?) -> Void)?) {
        var headers = [String: String]()
        if let token = resumeToken {
            headers["x-resume-token"] = token
        }
        session.request(certUpdateUrl,
                        method: .get,
                        parameters: nil,
                        encoding: URLEncoding(),
                        headers: .init(headers),
                        interceptor: nil,
                        requestModifier: nil)
            .response {
                guard let status = $0.response?.statusCode else {
                    completion?(nil, nil, "server.error.generic.error".localized)
                    return
                }
                
                // Everything ok, all certificates downloaded, no more content
                if status == 204 {
                    completion?(nil, nil, nil)
                    return
                }
                
                if status > 204 {
                    completion?(nil, nil, "server.error.error.with.status".localized + "\(status)")
                    return
                }
                
                guard
                    case let .success(result) = $0.result,
                    let response = result,
                    let responseStr = String(data: response, encoding: .utf8),
                    let headers = $0.response?.headers,
                    let responseKid = headers["x-kid"],
                    let newResumeToken = headers["x-resume-token"]
                else {
                    return
                }
                let kid = KID.from(responseStr)
                let kidStr = KID.string(from: kid)
                if kidStr != responseKid {
                    return
                }
                completion?(responseStr, newResumeToken, nil)
            }
    }
    
    private func status(completion: ((String?) -> Void)? = nil) {
        certStatus { validKids in
            let invalid = LocalData.sharedInstance.encodedPublicKeys.keys.filter {
                !validKids.contains($0)
            }
            for key in invalid {
                LocalData.sharedInstance.encodedPublicKeys.removeValue(forKey: key)
            }
            LocalData.sharedInstance.lastFetch = Date()
            LocalData.sharedInstance.save()
            completion?(nil)
        }
    }
    
    private func certStatus(resume resumeToken: String? = nil, completion: (([String]) -> Void)?) {
        session.request(certStatusUrl).response {
            guard
                case let .success(result) = $0.result,
                let response = result,
                let responseStr = String(data: response, encoding: .utf8),
                let json = JSON(parseJSON: responseStr).array
            else {
                return
            }
            let kids = json.compactMap { $0.string }
            if kids.isEmpty {
                LocalData.sharedInstance.resumeToken = nil
            }
            completion?(kids)
        }
    }
    
}

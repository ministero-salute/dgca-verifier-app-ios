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

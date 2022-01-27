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
import RxSwift

extension Bundle {
	func infoForKey(_ key: String) -> String? {
		return (Bundle.main.infoDictionary?[key] as? String)?.replacingOccurrences(of: "\\", with: "")
	}
}

enum ErrorInvoker {
    case drlStatus
    case drl
}

enum GCError: Error {
    case networkError(AFError)
    case httpError(Int)
    case noResponseError
    case decodeResponseError
}

struct ResponseError: Error{
    var underlyingError: GCError
    var invoker: ErrorInvoker
    
    init(error: GCError, invoker: ErrorInvoker){
        self.underlyingError = error
        self.invoker = invoker
    }
}

class GatewayConnection {
	
    let disposeBag = DisposeBag()
    
	let baseUrl: String
	let session: Session
	var timer: Timer?
	
	private let certificateFilename: String
	private let certificateEvaluator: String
	
	static let shared = GatewayConnection()
	
	private init() {
		baseUrl = Bundle.main.infoForKey("baseUrl")!
		certificateFilename = Bundle.main.infoForKey("certificateFilename")!
		certificateEvaluator = Bundle.main.infoForKey("certificateEvaluator")!
		
		// Init certificate for pinning
		let filePath = Bundle.main.path(forResource: certificateFilename, ofType: nil)!
		let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
		let certificate = SecCertificateCreateWithData(nil, data as CFData)!
		
		// Init session
		let evaluators = [certificateEvaluator: PinnedCertificatesTrustEvaluator(certificates: [certificate])]
		session = Session(serverTrustManager: ServerTrustManager(evaluators: evaluators))
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
	
	public func get<T: Codable>(url: String) -> RxSwift.Observable<T> {
		
        print("API GET \(T.self) url: \(url)")
        
		return RxSwift.Observable<T>.create{ observer in
			
			let request = self.session.request(url).response {
				
                let invoker = (T.self is DRL.Type) ? ErrorInvoker.drl : ErrorInvoker.drlStatus
                
				guard $0.error == nil else {
                    let gcError = GCError.networkError($0.error!)
                    observer.on(.error(ResponseError.init(error: gcError, invoker: invoker)))
					return
				}
				
				guard let response = $0.response else {
                    let gcError = GCError.noResponseError
                    observer.on(.error(ResponseError.init(error: gcError, invoker: invoker)))
					return
				}
				
				guard response.statusCode == 200 else {
					//error case
                    let gcError = GCError.httpError(response.statusCode)
                    observer.on(.error(ResponseError.init(error: gcError, invoker: invoker)))
					return
				}
				
				
				let decoder = JSONDecoder()
				let data = try? decoder.decode(T.self, from: $0.data ?? .init())
				
				guard let status = data else {
                    let gcError = GCError.decodeResponseError
                    observer.on(.error(ResponseError.init(error: gcError, invoker: invoker)))
					return
				}
				
				observer.on(.next(status))
				observer.on(.completed)
			}
			return Disposables.create { request.cancel() }
		}
		
	}
    
    public func get<T: Codable>(url: String) -> RxSwift.Single<T> {
        
        print("API GET \(T.self) url: \(url)")
        
        return RxSwift.Single<T>.create{ single in
            
            let request = self.session.request(url).response {
                
                guard $0.error == nil else {
                    let error = GCError.networkError($0.error!)
                    single(.failure(error))
                    return
                }
                
                guard let response = $0.response else {
                    single(.failure(GCError.noResponseError))
                    return
                }
                
                guard response.statusCode == 200 else {
                    //error case
                    single(.failure(GCError.httpError(response.statusCode)))
                    return
                }
                
                
                let decoder = JSONDecoder()
                let data = try? decoder.decode(T.self, from: $0.data ?? .init())
                
                guard let status = data else {
                    single(.failure(GCError.decodeResponseError))
                    return
                }
                
                single(.success(status))
            }
            return Disposables.create { request.cancel() }
        }
        
    }
	
	
}

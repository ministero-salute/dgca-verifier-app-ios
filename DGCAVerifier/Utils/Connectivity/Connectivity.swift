//
//  Connectivity.swift
//  Verifier
//
//  Created by Emilio Apuzzo on 09/11/21.
//

import Foundation
import Alamofire

class Connectivity {
    class var isOnline:Bool {
        NetworkReachabilityManager()?.isReachable ?? false
    }
}


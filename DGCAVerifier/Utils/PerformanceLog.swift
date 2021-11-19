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
//  PerformanceLog.swift
//  Verifier
//
//  Created by Andrea Prosseda on 25/08/21.
//

import Foundation

struct Log {
    
    static func start(key: String) -> CFAbsoluteTime {
        print("\(key) start at: \(now)")
        return currentAbsoluteTime
    }
    
    static func end(key: String, startTime: CFAbsoluteTime) {
        let timeElapsed = getTimeElapsed(from: startTime, to: currentAbsoluteTime)
        print("\(key) end at: \(now) in \(timeElapsed)")
    }
    
    private static func getTimeElapsed(from start: CFAbsoluteTime, to end: CFAbsoluteTime) -> String {
        let timeElapsed = end - start
        return String(format: "%.2f", timeElapsed)
    }
    
    private static var currentAbsoluteTime: CFAbsoluteTime { CFAbsoluteTimeGetCurrent() }
    private static var now: String { Date().toTimeReadableString }
    
}

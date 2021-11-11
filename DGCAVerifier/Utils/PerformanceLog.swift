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

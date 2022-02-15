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
//  Date+Math.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 25/06/21.
//

import Foundation

extension Date {
    
    static var startOfDay: Date? { Date().toDateString.toDate }
    
    var startOfDay: Date? { self.toDateString.toDate }
        
    func add(_ value: Int, ofType type: Calendar.Component) -> Date? {
        Calendar.current.date(byAdding: type, value: value, to: self)
    }
    
    func sub(_ value: Int, ofType type: Calendar.Component) -> Date? {
        Calendar.current.date(byAdding: type, value: -value, to: self)
    }
	
	func startOfMonth() -> Date {
		return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
	}
	
	func endOfMonth() -> Date {
		return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
	}
	
	func endOfYear() -> Date? {
		let components: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self)
		
		guard let month = components.month, let day = components.day else { return nil }
		
		return Calendar.current.date(byAdding: DateComponents(
			year: 1,
			month: -month + 1,
			day: -day
		), to: self)
	}
    
}

//
//  WeekdaysSupport.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/26.
//

import Foundation

class WeekdaysSupport {
    static let weekdays: Array<Locale.Weekday> = {
        let all: Array<Locale.Weekday> = [
            .sunday,
            .monday,
            .tuesday,
            .wednesday,
            .thursday,
            .friday,
            .saturday,
        ]
        return rotateArrayWithFirstWeekday(all)
    }()
    
    static let symbol: [String] = rotateArrayWithFirstWeekday(Calendar.current.weekdaySymbols)
    
    static let shortSymbol: [String] = rotateArrayWithFirstWeekday(Calendar.current.shortWeekdaySymbols)
    
    static let veryShortSymbol: [String] = rotateArrayWithFirstWeekday(Calendar.current.veryShortWeekdaySymbols)
    
    static func rotateArrayWithFirstWeekday<T>(_ array: [T]) -> [T] {
        let rotateCount = Calendar.current.firstWeekday - 1
        return Array(array[rotateCount...] + array[..<rotateCount])
    }
    
    static func isEveryday(_ array: Set<Locale.Weekday>) -> Bool {
        return array.count == 7
    }
    
    static func isWeekdayOnly(_ array: Set<Locale.Weekday>) -> Bool {
        return array.count == 5 && !array.contains(.sunday) && !array.contains(.saturday)
    }
}

//
//  AlarmData.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/18.
//

import AlarmKit
import SwiftData

struct AlarmData: Codable {
    static let userDefaultsKey = "AlarmData"
    
    var registeredAlarms: [UUID] = []
    
    var hour: Int = 9 { // 0 - 23
        didSet {
            if hour < 0 { hour = 0 }
            if hour > 23 { hour = 23 }
        }
    }
    
    var minute: Int = 0 { // 0 - 59
        didSet {
            if minute < 0 { minute = 0 }
            if minute > 59 { minute = 59 }
        }
    }
    
    var repeats: Set<Locale.Weekday> = [] // Empty = No repeat
    var sound: AlarmSound = AlarmSound.default
    var snoozeIntervalMinutes: Int = 9 { // 5 - 15
        didSet {
            if snoozeIntervalMinutes < 5 { snoozeIntervalMinutes = 5 }
            if snoozeIntervalMinutes > 15 { snoozeIntervalMinutes = 15 }
        }
    }
}

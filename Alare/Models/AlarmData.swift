//
//  AlarmData.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/18.
//

import AlarmKit
import SwiftData

struct AlarmData: AlarmMetadata, Codable {
    static let userDefaultsKey = "AlarmData"
    
    var registeredAlarm: UUID?

    var isEnabled: Bool = true
    
    var next: Date = Date() {
        didSet {
            // Clear seconds
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: next)
            next = calendar.date(from: components) ?? next
        }
    }
    
    var repeats: Set<Locale.Weekday> = [] // Empty = No repeat
    var sound: AlarmSound = AlarmSound.default
    var snoozeIntervalMinutes: Int = 9 { // 1 - 15
        didSet {
            if snoozeIntervalMinutes < 1 { snoozeIntervalMinutes = 1 }
            if snoozeIntervalMinutes > 15 { snoozeIntervalMinutes = 15 }
        }
    }
}

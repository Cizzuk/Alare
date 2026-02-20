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
    
    var isRegistering: Bool = false
    var registeredAlarms: [UUID] = []
    
    var isEnabled: Bool = true
    
    var next: Date = Date().addingTimeInterval(5 * 60) // +5 minutes
    var repeats: Set<Locale.Weekday> = [] // Empty = No repeat
    var sound: AlarmSound = AlarmSound.default
    var snoozeIntervalMinutes: Int = 9 { // 1 - 15
        didSet {
            if snoozeIntervalMinutes < 1 { snoozeIntervalMinutes = 1 }
            if snoozeIntervalMinutes > 15 { snoozeIntervalMinutes = 15 }
        }
    }
}

//
//  AlarmSettings.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/18.
//

import AlarmKit

struct AlarmSettings: AlarmMetadata, Codable {
    static let userDefaultsKey = "AlarmData"

    var isEnabled: Bool = false
    
    var next: Date = Date().addingTimeInterval(10 * 60) {
        didSet {
            next = AlarmSupport.cutSeconds(next)
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

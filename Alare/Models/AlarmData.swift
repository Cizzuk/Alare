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
    var hour: Int = 9 // 0 - 23
    var minute: Int = 0 // 0 - 59
    var repeats: [Locale.Weekday] = [] // Empty = No repeat
    var sound: AlarmSound = AlarmSound.default
    var snoozeIntervalMinutes: Int = 9 // 5 - 15
}

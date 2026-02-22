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
    
    var hour: Int = 9 {
        didSet { hour = clipInt(hour, min: 0, max: 23) }
    }
    
    var minute: Int = 0 {
        didSet { minute = clipInt(minute, min: 0, max: 59) }
    }
    
    var repeats: Set<Locale.Weekday> = [] // Empty = No repeat
    
    var sound: AlarmSound = AlarmSound.default
    
    var snoozeInterval: Int = 9 {
        didSet { snoozeInterval = clipInt(snoozeInterval, min: 1, max: 15) }
    }
    
    private func clipInt(_ value: Int, min: Int, max: Int) -> Int {
        if value < min { return min }
        if value > max { return max }
        return value
    }
}

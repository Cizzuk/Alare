//
//  AlarmSettings.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/18.
//

import AlarmKit
import MergeCodablePackage

struct AlarmSettings: AlarmMetadata, Codable {
    var isEnabled: Bool = false
    
    var hour: Int = 9 {
        didSet { hour = minute.clip(min: 0, max: 23) }
    }
    
    var minute: Int = 0 {
        didSet { minute = minute.clip(min: 0, max: 59) }
    }
    
    var repeats: Set<Locale.Weekday> = [] // Empty = No repeat
    
    var sound: AlarmSound = AlarmSound.default
    
    var isHardMode: Bool = false
    
    var snoozeInterval: Int = 9 {
        didSet { snoozeInterval = snoozeInterval.clip(min: 1, max: 30) }
    }
}

// MARK: - UserDefaults Persistence

@MainActor
extension AlarmSettings: MergeCodable {
    static let userDefaultsKey = "AlarmSettings"
    
    static func load() -> Self {
        guard let data = userDefaults.data(forKey: userDefaultsKey) else { return Self() }
        return decode(from: data)
    }
    
    func save() {
        if let data = encode() {
            userDefaults.set(data, forKey: Self.userDefaultsKey)
        }
    }
}

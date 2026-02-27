//
//  RegisteredAlarms.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/21.
//

import AlarmKit
import MergeCodablePackage

struct AlarmItem: Codable {
    var uuid: UUID
    var schedule: Alarm.Schedule
    var title: String.LocalizationValue
    var sound: AlarmSound
    var isSnooze: Bool = false
}

struct RegisteredAlarms: Codable {
    var mainAlarm: AlarmItem?
    
    var snoozeCount: Int = 0
    var nextSnooze: AlarmItem?
}

// MARK: - UserDefaults Persistence

extension RegisteredAlarms: MergeCodable {
    static let userDefaultsKey = "RegisteredAlarms"
    
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

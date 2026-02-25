//
//  RegisteredAlarms.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/21.
//

import AlarmKit

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

extension RegisteredAlarms {
    static let userDefaultsKey = "RegisteredAlarms"
    
    static func load() -> Self {
        if let rawData = userDefaults.data(forKey: RegisteredAlarms.userDefaultsKey) {
            if let data = try? JSONDecoder().decode(RegisteredAlarms.self, from: rawData) {
                return data
            }
        }
        return RegisteredAlarms()
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            userDefaults.set(data, forKey: RegisteredAlarms.userDefaultsKey)
        }
    }
}

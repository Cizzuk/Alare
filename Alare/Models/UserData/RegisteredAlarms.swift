//
//  RegisteredAlarms.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/21.
//

import AlarmKit

struct RegisteredAlarms: Codable {
    static let userDefaultsKey = "RegisteredAlarms"
    
    var mainAlarm: AlarmItem?
    var lastMainAlarmRegisteredDate: Date?
    
    var snoozeCount: Int = 0
    var nextSnooze: AlarmItem?
    
    var lastSnoozeOrKillDate: Date?
}

struct AlarmItem: Codable {
    var uuid: UUID
    var schedule: Alarm.Schedule
    var title: String.LocalizationValue
    var sound: AlarmSound
    var isSnooze: Bool = false
}

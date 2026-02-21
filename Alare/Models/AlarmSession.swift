//
//  AlarmSession.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/21.
//

import AlarmKit
import SwiftData

struct AlarmSession: AlarmMetadata, Codable {
    static let userDefaultsKey = "AlarmSession"
    
    var registeredAlarm: UUID?
    var registeredAlarmDate: Date?
    var isRegisteredAlarmSnooze: Bool = false
}

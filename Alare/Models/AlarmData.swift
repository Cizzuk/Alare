//
//  AlarmData.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/18.
//

import AlarmKit
import SwiftData

@Model
final class AlarmData {
    var registeredAlarms: [UUID] = []
    
    var hour: Int = 9 // 0 - 23
    var minute: Int = 0 // 0 - 59
    var repeats: Set<Weekday> = [] // Empty = no repeat
    var name: String = ""
    var sound: AlarmSound = AlarmSound.default
    var snoozeIntervalMinutes: Int = 9 // 5 - 15
    
    init() {}
    
    // Register next alarms
    func register() async {
        await unregister()
    }
    
    // Unregister all registered alarms
    func unregister() async {}
}

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
    // Setting an id and enabled for the future, but for now it's fixed to:
    @Attribute(.unique) var id: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    var enabled: Bool = true
    
    var registeredAlarms: [UUID] = []
    
    var hour: Int = 9 // 0 - 23
    var minute: Int = 0 // 0 - 59
    var repeats: [Locale.Weekday] = [] // Empty = No repeat
    var sound: AlarmSound = AlarmSound.default
    var snoozeIntervalMinutes: Int = 9 // 5 - 15
    
    init() {}
    
    func validate() async {
        
    }
    
    // Register next alarms
    func register() async {
        await unregister()
    }
    
    // Unregister all registered alarms
    func unregister() async {}
}

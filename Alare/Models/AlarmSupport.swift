//
//  AlarmSupport.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/19.
//

import ActivityKit
import AlarmKit
import Combine

// Manages user settings and communication with AlarmRegister

final class AlarmSupport: ObservableObject {
    static let shared = AlarmSupport()
    
    @ObservationIgnored private var register = AlarmRegister.shared
    
    @Published private(set) var settings: AlarmSettings = {
        if let rawData = userDefaults.data(forKey: AlarmSettings.userDefaultsKey) {
            if let data = try? JSONDecoder().decode(AlarmSettings.self, from: rawData) {
                return data
            }
        }
        return AlarmSettings()
    }() {
        didSet {
            if let data = try? JSONEncoder().encode(settings) {
                userDefaults.set(data, forKey: AlarmSettings.userDefaultsKey)
            }
        }
    }
    
    private init() {
        Task { await validate() }
    }
    
    func isAuthorizationDenied() async -> Bool {
        if AlarmManager.shared.authorizationState == .notDetermined {
            _ = try? await AlarmManager.shared.requestAuthorization()
        }
        
        if AlarmManager.shared.authorizationState == .denied {
            settings.isEnabled = false
            register.cancelMainAlarm()
            return true
        }
        
        return false
    }
    
    // Validate current settings and registered alarms
    func validate() async {
        // Remove invalid alarms from system
        try? await register.validateSystemAlarms()
        
        if await isAuthorizationDenied() { return }
        
        // If the alarm is disabled, kill
        if !settings.isEnabled {
            register.cancelMainAlarm()
            return
        }
    }
    
    // Push new settings and update main alarm
    func push(_ newAlarm: AlarmSettings) async {
        settings = newAlarm
        await sync()
    }
    
    // Sync settings to system alarm
    func sync() async {
        if await isAuthorizationDenied() { return }
        
        if !settings.isEnabled {
            register.cancelMainAlarm()
            return
        }
        
        // Create AlarmItem
        let uuid = UUID()
        
        // Create schedule
        let time = Alarm.Schedule.Relative.Time(
            hour: settings.hour,
            minute: settings.minute
        )
        
        let repeats: Alarm.Schedule.Relative.Recurrence = {
            if settings.repeats.isEmpty {
                return .never
            } else {
                return .weekly(Array(settings.repeats))
            }
        }()
        
        let schedule = Alarm.Schedule.relative(
            Alarm.Schedule.Relative(time: time, repeats: repeats)
        )
        
        let item = AlarmItem(
            uuid: uuid,
            schedule: schedule,
            title: "Alarm",
            sound: settings.sound
        )
        await register.pushMainAlarm(item: item)
    }
    
    func snooze() async {
        let uuid = UUID()
        
        let interval = TimeInterval(settings.snoozeInterval * 60)
        let date = Date().addingTimeInterval(interval)
        let schedule = Alarm.Schedule.fixed(date)
        
        let alarmItem = AlarmItem(
            uuid: uuid,
            schedule: schedule,
            title: "Snooze \(register.registereds.snoozeCount + 1)",
            sound: settings.sound
        )
        
        await register.pushSnooze(item: alarmItem)
    }
    
    // Stop the alarms completely
    func kill() async {
        register.killAlarm()
        
        // If the alarm is not set to repeat, disable it
        if settings.repeats.isEmpty {
            settings.isEnabled = false
            register.cancelMainAlarm()
        }
        
        await validate()
    }
}

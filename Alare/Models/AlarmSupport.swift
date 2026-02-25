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
    
    @Published private(set) var settings = AlarmSettings.load() {
        didSet { settings.save() }
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
            register.killAlarm()
            register.clearAllAlarmsFromSystem()
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
        
        // If there is nextSnooze but it's past time, reschedule snooze
        if let nextSnooze = register.registereds.nextSnooze,
           case .fixed(let date) = nextSnooze.schedule,
           date < Date() {
            await snooze()
            print("Snooze rescheduled due to past time")
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
            sound: settings.sound,
            isSnooze: false
        )
        await register.pushMainAlarm(item: item)
    }
    
    func alarmAction(uuid: UUID?) async {
        if let uuid = uuid {
            register.stopAlarm(uuid: uuid)
        }
        
        await snooze()
        
        // If the alarm is not set to repeat, disable it
        if settings.repeats.isEmpty {
            settings.isEnabled = false
            register.cancelMainAlarm()
        }
        
        await validate()
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
            sound: settings.sound,
            isSnooze: true
        )
        
        await register.pushSnooze(item: alarmItem)
    }
    
    // Stop the alarms completely
    func kill() async {
        register.killAlarm()
        await validate()
    }
    
    // MARK: - Public Helpers
    
    // Create Date from hour and minute
    static func makeDateFromTime(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        let base = calendar.startOfDay(for: Date())
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: base) ?? base
    }
    
    // Create hour and minute from Date
    static func makeTimeFromDate(_ date: Date) -> (hour: Int, minute: Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0, components.minute ?? 0)
    }
}

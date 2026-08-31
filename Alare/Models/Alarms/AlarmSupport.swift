//
//  AlarmSupport.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/19.
//

import ActivityKit
import AlarmKit
import Combine
import UIKit
import WidgetKit

// Manages user settings and communication with AlarmRegister

@MainActor
final class AlarmSupport: ObservableObject {
    static let shared = AlarmSupport()
    private static let hardModeSnoozeInterval: TimeInterval = 5
    private static let hardModeSnoozeIntervalVoiceOver: TimeInterval = 15
    
    @ObservationIgnored private var register = AlarmRegister.shared
    
    @Published private(set) var alarmSettings = AlarmSettings.load() {
        didSet {
            alarmSettings.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    @Published private(set) var wakeupCheckSettings = WakeupCheckSettings.load() {
        didSet {
            wakeupCheckSettings.save()
            WidgetCenter.shared.reloadAllTimelines()
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
            alarmSettings.isEnabled = false
            register.cancelMainAlarm()
            register.endSnooze()
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
        if !alarmSettings.isEnabled {
            register.cancelMainAlarm()
        }
        
        // If there is nextSnooze
        if let nextSnooze = register.registereds.nextSnooze,
           case .fixed(let date) = nextSnooze.schedule {
            // If it's past time, reschedule snooze
            if date < Date() {
                await addNextSnooze()
                print("Snooze rescheduled due to past time")
            }
            
            // Live Activity check
            if !SnoozeActivityManager.isActive() {
                SnoozeActivityManager.start()
                print("Snooze Live Activity restarted")
            }
        } else if SnoozeActivityManager.isActive() {
            // If there is no nextSnooze but Live Activity is active, end it
            SnoozeActivityManager.endAll()
        }
    }
    
    // Push new settings and update main alarm
    func push(_ newAlarm: AlarmSettings) async {
        alarmSettings = newAlarm
        await sync()
    }
    
    // Sync settings to system alarm
    func sync() async {
        if await isAuthorizationDenied() { return }
        
        if !alarmSettings.isEnabled {
            register.cancelMainAlarm()
            return
        }
        
        // Create AlarmItem
        let uuid = UUID()
        
        // Create schedule
        let time = Alarm.Schedule.Relative.Time(
            hour: alarmSettings.hour,
            minute: alarmSettings.minute
        )
        
        let repeats: Alarm.Schedule.Relative.Recurrence = {
            if alarmSettings.repeats.isEmpty {
                return .never
            } else {
                return .weekly(Array(alarmSettings.repeats))
            }
        }()
        
        let schedule = Alarm.Schedule.relative(
            Alarm.Schedule.Relative(time: time, repeats: repeats)
        )
        
        let item = AlarmItem(
            uuid: uuid,
            schedule: schedule,
            title: "Alarm",
            sound: alarmSettings.sound,
            isSnooze: false
        )
        await register.pushMainAlarm(item: item)
    }
    
    // Clear all snooze and check alarms
    func killAll() async {
        register.endSnooze()
        await validate()
        SnoozeActivityManager.endAll()
    }
    
    // MARK: - Wake-up Action Snooze
    
    func addNextSnoozeAction(uuid: UUID?) async {
        if let uuid = uuid {
            register.stopAlarm(uuid: uuid)
        }
        
        await addNextSnooze()
        
        // If the alarm is not set to repeat, disable it
        if alarmSettings.repeats.isEmpty {
            alarmSettings.isEnabled = false
            register.cancelMainAlarm()
        }
        
        await validate()
    }
    
    func addNextSnooze() async {
        let uuid = UUID()
        let interval: TimeInterval = createSnoozeInterval()
        let date = Date().addingTimeInterval(interval)
        let schedule = Alarm.Schedule.fixed(date)
        
        let alarmItem = AlarmItem(
            uuid: uuid,
            schedule: schedule,
            title: "Snooze \(register.registereds.snoozeCount + 1)",
            sound: alarmSettings.sound,
            isSnooze: true
        )
        
        await register.pushSnooze(item: alarmItem)
        if !SnoozeActivityManager.isActive() {
            SnoozeActivityManager.start()
        }
    }
    
    // End snooze completely
    func completeWakeupAction() async {
        register.endSnooze()
        await validate()
        SnoozeActivityManager.endAll()
    }
    
    // MARK: - Wake-up Check Snooze
    
    func scheduleWakeupCheckSnooze() async {
        let uuid = UUID()
        let interval = createSnoozeInterval() + TimeInterval(wakeupCheckSettings.startAfter * 60)
        let date = Date().addingTimeInterval(interval)
        let schedule = Alarm.Schedule.fixed(date)
        
        let alarmItem = AlarmItem(
            uuid: uuid,
            schedule: schedule,
            title: "Wake-up Check is Available",
            sound: alarmSettings.sound,
            isSnooze: true
        )
        
        let startTime = Date().addingTimeInterval(TimeInterval(wakeupCheckSettings.startAfter * 60))
        await register.pushWakeupCheckSnooze(item: alarmItem, startTime: startTime)
    }
    
    func completeWakeupCheck() async {
        register.endWakeupCheckSnooze()
        await validate()
    }
    
    // MARK: - Private Helpers
    
    private func createSnoozeInterval() -> TimeInterval {
        let interval: TimeInterval
        if alarmSettings.isHardMode {
            if UIAccessibility.isVoiceOverRunning {
                interval = Self.hardModeSnoozeIntervalVoiceOver
            } else {
                interval = Self.hardModeSnoozeInterval
            }
        } else {
            interval = TimeInterval(alarmSettings.snoozeInterval * 60)
        }
        return interval
    }
    
    // MARK: - Public Helpers
    
    // Create Date from hour and minute
    nonisolated static func makeDateFromTime(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        let base = calendar.startOfDay(for: Date())
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: base) ?? base
    }
    
    // Create hour and minute from Date
    nonisolated static func makeTimeFromDate(_ date: Date) -> (hour: Int, minute: Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0, components.minute ?? 0)
    }
}

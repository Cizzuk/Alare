//
//  AlarmRegister.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/22.
//

import ActivityKit
import AlarmKit
import Combine

// Communication with AlarmManager and manage registered alarms

final class AlarmRegister: ObservableObject {
    typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<AlarmSettings>
    static let shared = AlarmRegister()
    
    @ObservationIgnored private let alarmManager = AlarmManager.shared
    
    @Published private(set) var registereds: RegisteredAlarms = {
        if let rawData = UserDefaults.standard.data(forKey: RegisteredAlarms.userDefaultsKey) {
            if let alarmData = try? JSONDecoder().decode(RegisteredAlarms.self, from: rawData) {
                return alarmData
            }
        }
        return RegisteredAlarms()
    }() {
        didSet {
            if let data = try? JSONEncoder().encode(registereds) {
                UserDefaults.standard.set(data, forKey: RegisteredAlarms.userDefaultsKey)
            }
        }
    }
    
    private init() {}
    
    // MARK: - Registration
    
    func scheduleMainAlarm(item: AlarmItem) async {
        cancelMainAlarm()
        
        registereds.mainAlarm = item
        
        let alarmItem = AlarmItem(
            uuid: item.uuid,
            schedule: item.schedule,
            title: item.title,
            sound: item.sound
        )
        
        let configuration = AlarmPresets.makeConfiguration(item: alarmItem)
        
        try? await scheduleAlarmToSystem(uuid: item.uuid, configuration: configuration)
        print("Main alarm scheduled: \(item.uuid) with schedule: \(item.schedule)")
    }
    
    func cancelMainAlarm() {
        if let mainAlarm = registereds.mainAlarm {
            removeAlarm(uuid: mainAlarm.uuid)
            registereds.mainAlarm = nil
            print("Main alarm cancelled: \(mainAlarm.uuid)")
        }
    }
    
    // MARK: - Snooze
    
    func scheduleSnooze(interval: Int) async {
        cancelSnooze()
        
        let uuid = UUID()
        let date = Date().addingTimeInterval(TimeInterval(interval * 60))
        let schedule = Alarm.Schedule.fixed(date)
        
        registereds.snoozeCount += 1
        registereds.nextSnooze = AlarmItem(uuid: uuid, schedule: schedule)
        
        let alarmItem = AlarmItem(
            uuid: uuid,
            schedule: schedule,
            title: "Snooze \(registereds.snoozeCount)",
            sound: registereds.mainAlarm?.sound
        )
        
        let configuration = AlarmPresets.makeConfiguration(item: alarmItem)
        
        try? await scheduleAlarmToSystem(uuid: uuid, configuration: configuration)
        print("Snooze scheduled: \(uuid) at \(date)")
    }
    
    func cancelSnooze() {
        if let nextSnooze = registereds.nextSnooze {
            removeAlarm(uuid: nextSnooze.uuid)
            registereds.nextSnooze = nil
            print("Snooze cancelled: \(nextSnooze.uuid)")
        }
    }
    
    // MARK: - Alarm Control
    
    func stopAlarm(uuid: UUID) {
        try? alarmManager.stop(id: uuid)
    }
    
    func removeAlarm(uuid: UUID) {
        try? alarmManager.stop(id: uuid)
        try? alarmManager.cancel(id: uuid)
    }
    
    func killAlarm() {
        cancelSnooze()
        registereds.snoozeCount = 0
    }
    
    func validateSystemAlarms() async throws {
        let allSystemAlarms = try alarmManager.alarms
        let validAlarms = [registereds.mainAlarm, registereds.nextSnooze].compactMap { $0?.uuid }
        
        // Remove invalid alarms from the system
        for alarm in allSystemAlarms {
            if !validAlarms.contains(alarm.id) {
                removeAlarm(uuid: alarm.id)
                print("Found invalid alarm from system: \(alarm.id)")
            }
        }
        
        // Reschedule missing alarms to the system
        if let mainAlarm = registereds.mainAlarm,
           !allSystemAlarms.contains(where: { $0.id == mainAlarm.uuid }) {
            let alarmItem = AlarmItem(
                uuid: mainAlarm.uuid,
                schedule: mainAlarm.schedule,
                title: mainAlarm.title,
                sound: mainAlarm.sound
            )
            let configuration = AlarmPresets.makeConfiguration(item: alarmItem)
            try? await scheduleAlarmToSystem(uuid: mainAlarm.uuid, configuration: configuration)
            print("Main alarm missing from system, rescheduled: \(mainAlarm.uuid)")
        }
        
        if let nextSnooze = registereds.nextSnooze,
           !allSystemAlarms.contains(where: { $0.id == nextSnooze.uuid }) {
            let alarmItem = AlarmItem(
                uuid: nextSnooze.uuid,
                schedule: nextSnooze.schedule,
                title: "Snooze \(registereds.snoozeCount)",
                sound: registereds.mainAlarm?.sound
            )
            let configuration = AlarmPresets.makeConfiguration(item: alarmItem)
            try? await scheduleAlarmToSystem(uuid: nextSnooze.uuid, configuration: configuration)
            print("Snooze alarm missing from system, rescheduled: \(nextSnooze.uuid)")
        }
    }
    
    // MARK: - Communication with AlarmManager
    
    private func scheduleAlarmToSystem(uuid: UUID, configuration: AlarmConfiguration) async throws {
        _ = try await alarmManager.schedule(
            id: uuid,
            configuration: configuration
        )
    }
}

//
//  AlarmRegister.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/22.
//

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
        
        let uuid = item.uuid
        let schedule = item.schedule
        registereds.mainAlarm = item
        
        let configuration = AlarmPresets.makeConfiguration(uuid: uuid, schedule: schedule)
        try? await scheduleAlarmToSystem(uuid: uuid, configuration: configuration)
        print("Main alarm scheduled: \(uuid) with schedule: \(schedule)")
    }
    
    func cancelMainAlarm() {
        if let mainAlarm = registereds.mainAlarm {
            try? cancelAlarmFromSystem(uuid: mainAlarm.uuid)
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
        
        let configuration = AlarmPresets.makeConfiguration(uuid: uuid, schedule: schedule)
        try? await scheduleAlarmToSystem(uuid: uuid, configuration: configuration)
        print("Snooze scheduled: \(uuid) at \(date)")
    }
    
    func cancelSnooze() {
        if let nextSnooze = registereds.nextSnooze {
            try? cancelAlarmFromSystem(uuid: nextSnooze.uuid)
            registereds.nextSnooze = nil
            print("Snooze cancelled: \(nextSnooze.uuid)")
        }
    }
    
    // MARK: - Alarm Control
    
    func removeAlarm(uuid: UUID) {
        try? alarmManager.stop(id: uuid)
        try? alarmManager.cancel(id: uuid)
    }
    
    func killAlarm() {
        cancelSnooze()
        registereds.snoozeCount = 0
    }
    
    func validateSystemAlarms() throws {
        let allSystemAlarms = try alarmManager.alarms
        let validAlarms = [registereds.mainAlarm, registereds.nextSnooze].compactMap { $0?.uuid }
        
        for alarm in allSystemAlarms {
            if !validAlarms.contains(alarm.id) {
                removeAlarm(uuid: alarm.id)
                print("Found invalid alarm from system: \(alarm.id)")
            }
        }
    }
    
    // MARK: - Communication with AlarmManager
    
    private func scheduleAlarmToSystem(uuid: UUID, configuration: AlarmConfiguration) async throws {
        _ = try await alarmManager.schedule(
            id: uuid,
            configuration: configuration
        )
    }
    
    private func cancelAlarmFromSystem(uuid: UUID) throws {
        try alarmManager.cancel(id: uuid)
    }
    
    private func stopAlarmFromSystem(uuid: UUID) throws {
        try alarmManager.stop(id: uuid)
    }
}

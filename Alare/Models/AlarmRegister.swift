//
//  AlarmRegister.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/22.
//

import AlarmKit
import Combine

final class AlarmRegister {
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
        
        let configuration = AlarmPresets.makeConfiguration(schedule: schedule)
        try? await registerAlarmToSystem(uuid: uuid, configuration: configuration)
    }
    
    func cancelMainAlarm() {
        if let mainAlarm = registereds.mainAlarm {
            try? unregisterAlarmFromSystem(uuid: mainAlarm.uuid)
            registereds.mainAlarm = nil
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
        
        let configuration = AlarmPresets.makeConfiguration(schedule: schedule)
        try? await registerAlarmToSystem(uuid: uuid, configuration: configuration)
    }
    
    func cancelSnooze() {
        if let nextSnooze = registereds.nextSnooze {
            try? unregisterAlarmFromSystem(uuid: nextSnooze.uuid)
            registereds.nextSnooze = nil
        }
    }
    
    func stopSnooze() {
        cancelSnooze()
        registereds.snoozeCount = 0
    }
    
    // MARK: - Helpers, Private Methods
    
    private func registerAlarmToSystem(uuid: UUID, configuration: AlarmConfiguration) async throws {
        _ = try await alarmManager.schedule(
            id: uuid,
            configuration: configuration
        )
    }
    
    private func unregisterAlarmFromSystem(uuid: UUID) throws {
        try alarmManager.cancel(id: uuid)
    }
    
    private func stopAlarm(uuid: UUID) throws {
        try alarmManager.stop(id: uuid)
    }
}

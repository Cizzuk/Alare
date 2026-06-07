//
//  AlarmRegister.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/22.
//

import ActivityKit
import AlarmKit
import Combine
import WidgetKit

// Communication with AlarmManager and manage registered alarms

@MainActor
final class AlarmRegister: ObservableObject {
    typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<AlarmSettings>
    static let shared = AlarmRegister()
    
    @ObservationIgnored private let alarmManager = AlarmManager.shared
    
    @Published private(set) var registereds = RegisteredAlarms.load() {
        didSet {
            registereds.save()
            WidgetCenter.shared.reloadAllTimelines()
            ControlCenter.shared.reloadAllControls()
        }
    }
    
    private init() {}
    
    // MARK: - Registration
    
    func pushMainAlarm(item: AlarmItem) async {
        cancelMainAlarm()
        registereds.mainAlarm = item
        await scheduleMainAlarm()
    }
    
    // (Re)register current main alarm to the system
    private func scheduleMainAlarm() async {
        guard let item = registereds.mainAlarm else { return }
        let configuration = AlarmPresets.makeConfiguration(item: item)
        
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
    
    func pushSnooze(item: AlarmItem) async {
        cancelSnooze()
        registereds.snoozeCount += 1
        registereds.nextSnooze = item
        await scheduleSnooze()
    }
    
    // (Re)register current snooze to the system
    private func scheduleSnooze() async {
        guard let item = registereds.nextSnooze else { return }
        let configuration = AlarmPresets.makeConfiguration(item: item)
        
        try? await scheduleAlarmToSystem(uuid: item.uuid, configuration: configuration)
        print("Snooze scheduled: \(item.uuid) with schedule: \(item.schedule)")
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
            await scheduleMainAlarm()
            print("Main alarm missing from system, rescheduled: \(mainAlarm.uuid)")
        }
        
        if let nextSnooze = registereds.nextSnooze,
           !allSystemAlarms.contains(where: { $0.id == nextSnooze.uuid }) {
            await scheduleSnooze()
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
    
    func clearAllAlarmsFromSystem() {
        do {
            let allAlarms = try alarmManager.alarms
            for alarm in allAlarms {
                removeAlarm(uuid: alarm.id)
                print("Cleared alarm from system: \(alarm.id)")
            }
        } catch {
            print("Failed to clear alarms from system: \(error)")
        }
    }
    
    func testAlarm() async {
        let uuid = UUID()
        let date = Date().addingTimeInterval(5)
        let schedule = Alarm.Schedule.fixed(date)
        
        let alarmItem = AlarmItem(
            uuid: uuid,
            schedule: schedule,
            title: "Test Alarm",
            sound: AlarmSupport.shared.settings.sound,
            isSnooze: false
        )
        
        let configuration = AlarmPresets.makeConfiguration(item: alarmItem)
        
        try? await scheduleAlarmToSystem(uuid: alarmItem.uuid, configuration: configuration)
    }
}

//
//  AlarmSupport.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/19.
//

import ActivityKit
import AlarmKit
import Combine
import Foundation

final class AlarmSupport: ObservableObject {
    typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<AlarmData>
    
    static let shared = AlarmSupport()
    @ObservationIgnored private let alarmManager = AlarmManager.shared
    
    @Published private(set) var alarm: AlarmData = {
        if let rawData = UserDefaults.standard.data(forKey: AlarmData.userDefaultsKey) {
            if let alarmData = try? JSONDecoder().decode(AlarmData.self, from: rawData) {
                return alarmData
            }
        }
        return AlarmData()
    }()
    
    private func save() {
        if let data = try? JSONEncoder().encode(alarm) {
            UserDefaults.standard.set(data, forKey: AlarmData.userDefaultsKey)
        }
    }
    
    private init() {
        Task { await validate() }
    }
    
    func update(_ newAlarm: AlarmData) async {
        alarm = newAlarm
        await register(date: alarm.next)
    }
    
    // Stop the alarm and set the next one if needed
    func stop() async {
        await unregister()
    }
    
    func snooze() async {
        let snoozeInterval = alarm.snoozeIntervalMinutes
        let date = Date().addingTimeInterval(TimeInterval(snoozeInterval * 60))
        await register(date: date, isSnooze: true)
    }
    
    func validate() async {
        if !alarm.isEnabled {
            await unregister()
            return
        }
        
        // if the last registered alarm has passed
    }
    
    // (Re)Register next alarms
    func register(date: Date, isSnooze: Bool = false) async {
        await unregister()
        
        let uuid = UUID()
        alarm.registeredAlarm = uuid
        alarm.registeredAlarmDate = date
        alarm.isRegisteredAlarmSnooze = isSnooze
        
        let configuration = AlermPresets.makeConfiguration(date: date)
        await registerAlarmToSystem(uuid: uuid, configuration: configuration)
        
        save()
    }
    
    // Unregister all registered alarms
    func unregister() async {
        if let uuid = alarm.registeredAlarm {
            await unregisterAlarmFromSystem(uuid: uuid)
            alarm.registeredAlarm = nil
            save()
        }
    }
    
    // MARK: - Helpers, Private Methods
    
    private func registerAlarmToSystem(uuid: UUID, configuration: AlarmConfiguration) async {
        do {
            let alarm = try await alarmManager.schedule(
                id: uuid,
                configuration: configuration
            )
            print("Alarm scheduled with ID: \(alarm.id)")
        } catch {
            print("Error encountered when scheduling alarm: \(error), ID: \(uuid)")
        }
    }
    
    private func unregisterAlarmFromSystem(uuid: UUID) async {
        do {
            try alarmManager.cancel(id: uuid)
            print("Alarm cancelled with ID: \(uuid)")
        } catch {
            print("Error encountered when cancelling alarm with ID \(uuid): \(error)")
        }
    }

}

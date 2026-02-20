//
//  AlarmManager.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/19.
//

import AlarmKit
import Combine
import Foundation

final class AlarmManager: ObservableObject {
    static let shared = AlarmManager()
    
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
        await register()
    }
    
    // Stop the alarm and set the next one if needed
    func stop() async {}
    
    func validate() async {
        // if the registering flag is true
        if alarm.isRegistering {
            await register()
            return
        }
        
        if !alarm.isEnabled {
            await unregister()
            return
        }
        
        // if the last registered alarm has passed
    }
    
    // (Re)Register next alarms
    func register() async {
        await unregister()
        if !alarm.isEnabled { return }
        
        let uuids = createUUIDs()
        alarm.registeredAlarms = uuids
        alarm.isRegistering = true
        save()
        
        // Register alarms to the system
        let startDate = alarm.next
        var currentDate = startDate
        for uuid in uuids {
            await registerAlarmToSystem(uuid: uuid, date: currentDate)
        }
        
        alarm.isRegistering = false
        save()
    }
    
    // Unregister all registered alarms
    func unregister() async {
        alarm.isRegistering = true
        save()
        
        for uuid in alarm.registeredAlarms {
            await unregisterAlarmFromSystem(uuid: uuid)
        }
        
        alarm.registeredAlarms = []
        alarm.isRegistering = false
        save()
    }
    
    // MARK: - Helpers, Private Methods
    
    private func createUUIDs() -> [UUID] {
        var uuids: [UUID] = []
        
        // Check how many alarms we need to register
        //
        let alarmSessionMinutes = 4*60 // 4 hours
        let alarmIntervalMinutes = alarm.snoozeIntervalMinutes
        let totalAlarms = alarmSessionMinutes / alarmIntervalMinutes
        
        for _ in 0..<totalAlarms {
            uuids.append(UUID())
        }
        return uuids
    }
    
    private func registerAlarmToSystem(uuid: UUID, date: Date) async {
        
    }
    
    private func unregisterAlarmFromSystem(uuid: UUID) async {
    }

}

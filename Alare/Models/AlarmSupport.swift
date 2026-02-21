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
    }() {
        didSet {
            if let data = try? JSONEncoder().encode(alarm) {
                UserDefaults.standard.set(data, forKey: AlarmData.userDefaultsKey)
            }
        }
    }
    
    @Published private(set) var session: AlarmSession = {
        if let rawData = UserDefaults.standard.data(forKey: AlarmSession.userDefaultsKey) {
            if let alarmData = try? JSONDecoder().decode(AlarmSession.self, from: rawData) {
                return alarmData
            }
        }
        return AlarmSession()
    }() {
        didSet {
            if let data = try? JSONEncoder().encode(session) {
                UserDefaults.standard.set(data, forKey: AlarmSession.userDefaultsKey)
            }
        }
    }
    
    private init() {
        Task { await validate() }
    }
    
    func update(_ newAlarm: AlarmData) async {
        alarm = newAlarm
        if alarm.isEnabled {
            await register(date: alarm.next)
        } else {
            await clear()
        }
    }
    
    func snooze() async {
        session.isSnoozing = true
        session.snoozes.append(Date())
        
        // Create new alarm
        let snoozeInterval = alarm.snoozeIntervalMinutes
        let date = Date().addingTimeInterval(TimeInterval(snoozeInterval * 60))
        await register(date: date, isSnooze: true)
    }
    
    // Stop the alarm and set the next one if needed
    func stop() async {
        await clear()
        session.isSnoozing = false
        session.snoozes.removeAll()
        
        // If the alarm is repeating, register the next one
    }
    
    func validate() async {
        if !alarm.isEnabled {
            await clear()
            return
        }
        
        // if the last registered alarm has passed
    }
    
    func clear() async {
        await unregister()
        session = AlarmSession()
        await validate()
    }
    
    // (Re)Register next alarms
    func register(date: Date, isSnooze: Bool = false) async {
        await unregister()
        
        let uuid = UUID()
        session.registeredAlarm = uuid
        session.registeredAlarmDate = date
        
        let configuration = AlermPresets.makeConfiguration(date: date)
        await registerAlarmToSystem(uuid: uuid, configuration: configuration)
    }
    
    // Unregister all registered alarms
    func unregister() async {
        if let uuid = session.registeredAlarm {
            await unregisterAlarmFromSystem(uuid: uuid)
            session.registeredAlarm = nil
            session.registeredAlarmDate = nil
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

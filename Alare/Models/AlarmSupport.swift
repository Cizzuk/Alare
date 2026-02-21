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
    typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<AlarmSettings>
    
    static let shared = AlarmSupport()
    @ObservationIgnored private let alarmManager = AlarmManager.shared
    
    @Published private(set) var settings: AlarmSettings = {
        if let rawData = UserDefaults.standard.data(forKey: AlarmSettings.userDefaultsKey) {
            if let alarmData = try? JSONDecoder().decode(AlarmSettings.self, from: rawData) {
                return alarmData
            }
        }
        return AlarmSettings()
    }() {
        didSet {
            if let data = try? JSONEncoder().encode(settings) {
                UserDefaults.standard.set(data, forKey: AlarmSettings.userDefaultsKey)
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
    
    func update(_ newAlarm: AlarmSettings) async {
        settings = newAlarm
        if settings.isEnabled {
            await register(date: settings.next)
        } else {
            await unregister()
            session = AlarmSession()
        }
    }
    
    func snooze() async {
        session.isSnoozing = true
        session.snoozes.append(Date())
        
        // Create new alarm
        let snoozeInterval = settings.snoozeIntervalMinutes
        let date = Date().addingTimeInterval(TimeInterval(snoozeInterval * 60))
        await register(date: date)
    }
    
    // Stop the alarm and set the next one if needed
    func stop() async {
        await unregister()
        session.isSnoozing = false
        session.snoozes.removeAll()
        
        // If the alarm is repeating, register the next one
    }
    
    func validate() async {
        if !settings.isEnabled {
            await unregister()
            return
        }
        
        // if the last registered alarm has passed
    }
    
    // (Re)Register next alarms
    func register(date: Date) async {
        await unregister()
        
        let uuid = UUID()
        session.registeredAlarm = uuid
        session.registeredAlarmDate = date
        
        let configuration = AlermPresets.makeConfiguration(date: date)
        
        do {
            try await registerAlarmToSystem(uuid: uuid, configuration: configuration)
            print("Registered alarm with ID: \(uuid), Date: \(date)")
        } catch {
            session.registeredAlarm = nil
            session.registeredAlarmDate = nil
            print("Error encountered when registering alarm: \(error), ID: \(uuid)")
        }
    }
    
    // Unregister all registered alarms
    func unregister() async {
        if let uuid = session.registeredAlarm {
            do {
                try await unregisterAlarmFromSystem(uuid: uuid)
                session.registeredAlarm = nil
                session.registeredAlarmDate = nil
                print("Unregistered alarm with ID: \(uuid)")
            } catch {
                print("Error encountered when unregistering alarm: \(error), ID: \(uuid)")
            }
        }
    }
    
    // MARK: - Helpers, Private Methods
    
    private func registerAlarmToSystem(uuid: UUID, configuration: AlarmConfiguration) async throws {
        _ = try await alarmManager.schedule(
            id: uuid,
            configuration: configuration
        )
    }
    
    private func unregisterAlarmFromSystem(uuid: UUID) async throws {
        try alarmManager.cancel(id: uuid)
    }

}

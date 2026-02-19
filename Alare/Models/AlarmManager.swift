//
//  AlarmManager.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/19.
//

import Combine
import Foundation

final class AlarmManager: ObservableObject {
    static let shared = AlarmManager()
    
    @Published var alarm: AlarmData = {
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
    
    private init() {}
    
    func validate() async {
        
    }
    
    // Register next alarms
    func register() async {
        await unregister()
    }
    
    // Unregister all registered alarms
    func unregister() async {}
}

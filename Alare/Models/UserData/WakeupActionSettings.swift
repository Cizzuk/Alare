//
//  WakeupActionSettings.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/23.
//

import Foundation

struct WakeupActionSettings: Codable {
    var selected: WakeupAction = .default
    
    // Wave Device Settings
    var waveDevice_pointsRequired: Int = 100
    
    // Scan Code Settings
    var scanCode_code: String? // Required
    
    // Drum Roll Settings
    var drumRoll_tapsRequired: Int = 100
}

// MARK: - UserDefaults Persistence

extension WakeupActionSettings {
    static let userDefaultsKey = "WakeupActionSettings"
    
    static func load() -> Self {
        if let rawData = userDefaults.data(forKey: WakeupActionSettings.userDefaultsKey) {
            if let data = try? JSONDecoder().decode(WakeupActionSettings.self, from: rawData) {
                return data
            }
        }
        return WakeupActionSettings()
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            userDefaults.set(data, forKey: WakeupActionSettings.userDefaultsKey)
        }
    }
}

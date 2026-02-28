//
//  WakeupActionSettings.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/23.
//

import Foundation
import MergeCodablePackage

struct WakeupActionSettings: Codable {
    var selected: WakeupAction = .default
    
    // Wave Device Settings
    var waveDevice_pointsRequired: Int = 100
    var waveDevice_sensitivity: Double = 0.5
    
    // Scan Code Settings
    var scanCode_code: String? // Required
    
    // Drum Roll Settings
    var drumRoll_tapsRequired: Int = 100
}

// MARK: - UserDefaults Persistence

extension WakeupActionSettings: MergeCodable {
    static let userDefaultsKey = "WakeupActionSettings"
    
    static func load() -> Self {
        guard let data = userDefaults.data(forKey: userDefaultsKey) else { return Self() }
        return decode(from: data)
    }
    
    func save() {
        if let data = encode() {
            userDefaults.set(data, forKey: Self.userDefaultsKey)
        }
    }
}

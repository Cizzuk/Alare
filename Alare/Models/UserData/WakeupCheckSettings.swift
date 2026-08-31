//
//  WakeupCheckSettings.swift
//  Alare
//
//  Created by Cizzuk on 2026/08/17.
//

import AlarmKit
import MergeCodablePackage

struct WakeupCheckSettings: AlarmMetadata, Codable {
    var isEnabled: Bool = false
    var startAfter: Int = 9 {
        didSet { startAfter = startAfter.clip(min: 1, max: 15) }
    }
}

// MARK: - UserDefaults Persistence

@MainActor
extension WakeupCheckSettings: MergeCodable {
    static let userDefaultsKey = "WakeupCheckSettings"
    
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

//
//  WakeupActionManager.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/23.
//

import Combine
import Foundation

final class WakeupActionManager: ObservableObject {
    static let shared = WakeupActionManager()
    
    @Published var settings: WakeupActionSettings = {
        if let rawData = userDefaults.data(forKey: WakeupActionSettings.userDefaultsKey) {
            if let data = try? JSONDecoder().decode(WakeupActionSettings.self, from: rawData) {
                return data
            }
        }
        return WakeupActionSettings()
    }() {
        didSet {
            if let data = try? JSONEncoder().encode(settings) {
                userDefaults.set(data, forKey: WakeupActionSettings.userDefaultsKey)
            }
        }
    }
    
    private init() {}
}

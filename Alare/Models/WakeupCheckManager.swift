//
//  WakeupCheckManager.swift
//  Alare
//
//  Created by Cizzuk on 2026/08/31.
//

import Combine
import UserNotifications

@MainActor
final class WakeupCheckManager: ObservableObject {
    static let shared = WakeupCheckManager()
    
    @Published var settings = WakeupCheckSettings.load() {
        didSet { settings.save() }
    }
    
    private init() {}
    
    func validate() async {
        if await UserNotificationSupport.authorizationStatus() != .authorized {
            settings.isEnabled = false
        }
    }
}

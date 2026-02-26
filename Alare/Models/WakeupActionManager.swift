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
    
    @Published var settings = WakeupActionSettings.load() {
        didSet { settings.save() }
    }
    
    private init() {}
    
    func validate() {
        if !settings.selected.isAvailable() {
            if WakeupAction.default.isAvailable() {
                settings.selected = .default
            }
        }
    }
}

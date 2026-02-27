//
//  StartWakeupActionIntent.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/25.
//

import AppIntents
import SwiftUI
import WidgetKit

struct StartWakeupActionIntent: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "StartWakeupAction"
    static var title: LocalizedStringResource = "Open Alare and Start Wake-up Action"
    static var description: LocalizedStringResource = "Open Alare and start the Wake-up Action. The action will not start if the alarm is not snoozing."
    
    static var openAppWhenRun = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .shouldStartWakeupAction, object: nil)
        return .result()
    }
}

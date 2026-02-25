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
    static var title: LocalizedStringResource = "Start Wake-up Action"
    static var description: LocalizedStringResource = "Open the Alare and start the Wake-up Action. The action will not start if the alarm is not snoozing."
    
    static var openAppWhenRun = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .shouldStartWakeupAction, object: nil)
        return .result()
    }
}

struct StartWakeupActionControl: ControlWidget {
    static let kind = "net.cizzuk.alare.WidgetExtension.StartWakeupActionControl"
    static let title: LocalizedStringResource = StartWakeupActionIntent.title
    
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: StartWakeupActionControl.kind) {
            ControlWidgetButton(action: StartWakeupActionIntent()) {
                Label(StartWakeupActionControl.title, image: "bolt.alare")
            }
        }
        .displayName(StartWakeupActionControl.title)
    }
}

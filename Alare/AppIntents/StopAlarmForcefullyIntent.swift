//
//  StopAlarmForcefullyIntent.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/25.
//

import AppIntents
import WidgetKit

struct StopAlarmForcefullyIntent: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "StopAlarmForcefully"
    static var title: LocalizedStringResource = "Stop Current Alarm and Snooze Forcefully"
    static var description: LocalizedStringResource = "Even without a Wake-up Action, running this shortcut will forcefully stop the current alarm and snooze."
    
    @MainActor
    func perform() async throws -> some IntentResult {
        let support = AlarmSupport.shared
        await support.kill()
        NotificationCenter.default.post(name: .alarmSettingsDidChangeOutsideMainApp, object: nil)
        
        return .result()
    }
}

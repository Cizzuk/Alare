//
//  ChangeAlarmTimeIntent.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/25.
//

import AppIntents
import WidgetKit

struct ChangeAlarmTimeIntent: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "ChangeAlarmTime"
    static var title: LocalizedStringResource = "Change Alare's Alarm Time"
    static var description: LocalizedStringResource = "Changes the time of the Alare's alarm."
    
    @Parameter(title: "Time", kind: .time)
    var time: Date
    
    static var parameterSummary: some ParameterSummary {
        Summary("Change Alare's Alarm Time to \(\.$time)")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        let support = AlarmSupport.shared
        var settings = support.settings
        
        let (hour, minute) = AlarmSupport.makeTimeFromDate(time)
        if settings.hour != hour || settings.minute != minute {
            settings.hour = hour
            settings.minute = minute
        }
        
        await support.push(settings)
        NotificationCenter.default.post(name: .alarmSettingsDidChangeOutsideMainApp, object: nil)
        
        return .result()
    }
}

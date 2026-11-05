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
    static let title: LocalizedStringResource = "Change Alare's Alarm Time"
    static let description: LocalizedStringResource = "Changes the time of Alare's alarm."

    @Parameter(title: "Time", kind: .time)
    var time: Date

    static var parameterSummary: some ParameterSummary {
        Summary("Change Alare's Alarm Time to \(\.$time)")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let support = AlarmSupport.shared
        var settings = support.alarmSettings

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

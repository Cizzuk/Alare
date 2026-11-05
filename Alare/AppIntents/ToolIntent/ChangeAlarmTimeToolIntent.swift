//
//  ChangeAlarmTimeToolIntent.swift
//  Alare
//
//  Created by Cizzuk on 2026/11/05.
//

import AppIntents
import WidgetKit

@available(iOS 27.3, *)
@AppIntent(.tool)
struct ChangeAlarmTimeToolIntent: AppIntent {
    static var title: LocalizedStringResource = "[ToolIntent] ChangeAlarmTimeToolIntent.title"
    static var description: LocalizedStringResource = "[ToolIntent] ChangeAlarmTimeToolIntent.description"

    @Parameter(title: "Time", kind: .time)
    var time: Date

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

//
//  SetUseAlarmToolIntent.swift
//  Alare
//
//  Created by Cizzuk on 2026/11/05.
//

import AppIntents
import WidgetKit

@available(iOS 27.3, *)
@AppIntent(.tool)
struct SetUseAlarmToolIntent: AppIntent {
    static let title: LocalizedStringResource = "[ToolIntent] SetUseAlarmToolIntent.title"
    static let description: LocalizedStringResource = "[ToolIntent] SetUseAlarmToolIntent.description"
    static let isDiscoverable: Bool = false

    @Parameter(title: "State")
    var state: Bool

    @MainActor
    func perform() async throws -> some IntentResult {
        let support = AlarmSupport.shared
        var settings = support.alarmSettings

        settings.isEnabled = state

        await support.push(settings)
        NotificationCenter.default.post(name: .alarmSettingsDidChangeOutsideMainApp, object: nil)

        return .result()
    }
}

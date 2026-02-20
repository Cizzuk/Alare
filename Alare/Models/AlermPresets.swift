//
//  AlermPresets.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/20.
//

import AlarmKit
import AppIntents
import SwiftUI

final class AlermPresets {
    typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<AlarmData>
    
    static let content = AlarmPresentation.Alert(
        title: "Alarm",
        secondaryButton: .stopWithAction,
        secondaryButtonBehavior: .custom
    )
    
    static let attributes = AlarmAttributes<AlarmData>(
        presentation: AlarmPresentation(alert: content),
        tintColor: .accent
    )
    
    static func makeConfiguration(date: Date) -> AlarmConfiguration {
        return AlarmConfiguration(
            schedule: .fixed(date),
            attributes: Self.attributes,
            stopIntent: SnoozeIntent(),
            secondaryIntent: OpenAppIntent()
        )
    }
}

extension AlarmButton {
    static var snoozeButton: Self {
        AlarmButton(text: "Snooze", textColor: .white, systemImageName: "forward.fill")
    }
    
    static var stopWithAction: Self {
        AlarmButton(text: "Stop with Action", textColor: .white, systemImageName: "stop.circle")
    }
}

struct OpenAppIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Open Alare"
    static var openAppWhenRun = true
    static var isDiscoverable = false
    
    func perform() throws -> some IntentResult {
        Task { await AlarmSupport.shared.snooze() }
        return .result()
    }
}

struct SnoozeIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Snooze"
    static var openAppWhenRun = false
    static var isDiscoverable = false
    
    func perform() throws -> some IntentResult {
        Task { await AlarmSupport.shared.snooze() }
        return .result()
    }
}

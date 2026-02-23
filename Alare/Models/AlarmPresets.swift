//
//  AlarmPresets.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/20.
//

import ActivityKit
import AlarmKit
import AppIntents
import SwiftUI

final class AlarmPresets {
    typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<AlarmSettings>
    
    static func makeConfiguration(item: AlarmItem) -> AlarmConfiguration {
        let uuidString = item.uuid.uuidString
        let titleLocalized = item.title ?? "Alarm"
        let alertSound = item.sound?.alertSound ?? AlarmSound.default.alertSound
        
        let content = AlarmPresentation.Alert(
            title: LocalizedStringResource(titleLocalized),
            secondaryButton: .snoozeButton,
            secondaryButtonBehavior: .custom
        )
        
        let attributes = AlarmAttributes<AlarmSettings>(
            presentation: AlarmPresentation(alert: content),
            tintColor: .dropblue
        )
        
        return AlarmConfiguration(
            schedule: item.schedule,
            attributes: attributes,
            stopIntent: OpenAppIntent(uuid: uuidString),
            secondaryIntent: SnoozeIntent(uuid: uuidString),
            sound: alertSound
        )
    }
}

extension AlarmButton {
    static var snoozeButton: Self {
        AlarmButton(text: "Snooze", textColor: .white, systemImageName: "bed.double.fill")
    }
    
    static var stopWithAction: Self {
        AlarmButton(text: "Stop in Alare", textColor: .white, systemImageName: "stop.circle")
    }
}

struct OpenAppIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Open Alare"
    static var openAppWhenRun = true
    static var isDiscoverable = false
    
    @Parameter(title: "UUID")
    var uuid: String
    init(uuid: String) { self.uuid = uuid }
    init() { self.uuid = "" }
    
    func perform() throws -> some IntentResult {
        Task { await AlarmSupport.shared.snooze() }
        if let uuid = UUID(uuidString: uuid) {
            AlarmRegister.shared.stopAlarm(uuid: uuid)
        }
        return .result()
    }
}

struct SnoozeIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Snooze"
    static var openAppWhenRun = false
    static var isDiscoverable = false
    
    @Parameter(title: "UUID")
    var uuid: String
    init(uuid: String) { self.uuid = uuid }
    init() { self.uuid = "" }
    
    func perform() throws -> some IntentResult {
        Task { await AlarmSupport.shared.snooze() }
        if let uuid = UUID(uuidString: uuid) {
            AlarmRegister.shared.stopAlarm(uuid: uuid)
        }
        return .result()
    }
}

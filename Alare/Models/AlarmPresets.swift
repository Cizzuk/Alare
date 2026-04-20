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
    
    @MainActor
    static func makeConfiguration(item: AlarmItem) -> AlarmConfiguration {
        let uuidString = item.uuid.uuidString
        let titleLocalized = item.title
        let alertSound = item.isSnooze ? item.sound.alertSoundSnooze : item.sound.alertSound
        let isHardMode = AlarmSupport.shared.settings.isHardMode

        let secondaryButton: AlarmButton = isHardMode ? .wakeUpButton : .snoozeButton
        
        let content = AlarmPresentation.Alert(
            title: LocalizedStringResource(titleLocalized),
            secondaryButton: secondaryButton,
            secondaryButtonBehavior: .custom
        )
        
        let attributes = AlarmAttributes<AlarmSettings>(
            presentation: AlarmPresentation(alert: content),
            tintColor: .dropblue
        )
        
        if isHardMode {
            return AlarmConfiguration(
                schedule: item.schedule,
                attributes: attributes,
                stopIntent: HardModeAlarmActionIntent(uuid: uuidString),
                secondaryIntent: HardModeAlarmActionIntent(uuid: uuidString),
                sound: alertSound
            )
        } else {
            return AlarmConfiguration(
                schedule: item.schedule,
                attributes: attributes,
                stopIntent: AlarmStartWakeupActionIntent(uuid: uuidString),
                secondaryIntent: AlarmSnoozeIntent(uuid: uuidString),
                sound: alertSound
            )
        }
    }
}

extension AlarmButton {
    static var snoozeButton: Self {
        AlarmButton(text: "Snooze", textColor: .white, systemImageName: "zzz")
    }
    
    static var stopWithAction: Self {
        AlarmButton(text: "Stop in Alare", textColor: .white, systemImageName: "stop.circle")
    }

    static var wakeUpButton: Self {
        AlarmButton(text: "Wake Up", textColor: .white, systemImageName: "alarm.waves.left.and.right")
    }
}

struct AlarmStartWakeupActionIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Start Wake-up Action"
    static var openAppWhenRun = false
    static var isDiscoverable = false
    
    @Parameter(title: "UUID")
    var uuid: String
    init(uuid: String) { self.uuid = uuid }
    init() { self.uuid = "" }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        let uuid = UUID(uuidString: uuid)
        await AlarmSupport.shared.alarmAction(uuid: uuid)
        return .result(opensIntent: StartWakeupActionIntent())
    }
}

struct AlarmSnoozeIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Snooze"
    static var openAppWhenRun = false
    static var isDiscoverable = false
    
    @Parameter(title: "UUID")
    var uuid: String
    init(uuid: String) { self.uuid = uuid }
    init() { self.uuid = "" }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        let uuid = UUID(uuidString: uuid)
        await AlarmSupport.shared.alarmAction(uuid: uuid)
        return .result()
    }
}

struct HardModeAlarmActionIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Wake Up"
    static var openAppWhenRun = true
    static var isDiscoverable = false

    @Parameter(title: "UUID")
    var uuid: String
    init(uuid: String) { self.uuid = uuid }
    init() { self.uuid = "" }

    @MainActor
    func perform() async throws -> some IntentResult {
        let uuid = UUID(uuidString: uuid)
        await AlarmSupport.shared.alarmAction(uuid: uuid)
        userDefaults.set(true, forKey: shouldStartWakeupActionOnLaunchKey)
        return .result()
    }
}

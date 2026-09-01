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
        let isHardMode = AlarmSupport.shared.alarmSettings.isHardMode
        
        let content: AlarmPresentation.Alert
        if item.isWakeupCheck {
            content = AlarmPresentation.Alert(
                title: LocalizedStringResource(titleLocalized),
                secondaryButton: nil,
                secondaryButtonBehavior: .none
            )
        } else if isHardMode {
            content = AlarmPresentation.Alert(
                title: LocalizedStringResource(titleLocalized),
                secondaryButton: nil,
                secondaryButtonBehavior: .none
            )
        } else {
            content = AlarmPresentation.Alert(
                title: LocalizedStringResource(titleLocalized),
                secondaryButton: .snoozeButton,
                secondaryButtonBehavior: .custom
            )
        }
        
        let stopIntent: any LiveActivityIntent
        let secondaryIntent: any LiveActivityIntent?
        if item.isWakeupCheck {
            stopIntent = AlarmCompleteWakeupCheckIntent(uuid: uuidString)
            secondaryIntent = nil
        } else if isHardMode {
            stopIntent = AlarmSnoozeIntent(uuid: uuidString)
            secondaryIntent = nil
        } else {
            stopIntent = AlarmStartWakeupActionIntent(uuid: uuidString)
            secondaryIntent = AlarmSnoozeIntent(uuid: uuidString)
        }
        
        let attributes = AlarmAttributes<AlarmSettings>(
            presentation: AlarmPresentation(alert: content),
            tintColor: .dropblue
        )
        
        /// Version 1.3 : To prevent issues where snooze is not set correctly, the Wake-up Action is no longer automatically started when stopping an alarm in Hard Mode
        return AlarmConfiguration(
            schedule: item.schedule,
            attributes: attributes,
            stopIntent: stopIntent,
            secondaryIntent: secondaryIntent,
            sound: alertSound
        )
    }
}

extension AlarmButton {
    static var snoozeButton: Self {
        AlarmButton(text: "Snooze", textColor: .white, systemImageName: "zzz")
    }
    
    static var stopWithAction: Self {
        AlarmButton(text: "Stop in Alare", textColor: .white, systemImageName: "stop.circle")
    }
    
    static var completeWakeupCheck: Self {
        AlarmButton(text: "Complete Wake-up Check", textColor: .white, systemImageName: "checkmark")
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
        await AlarmSupport.shared.addNextSnoozeAction(uuid: uuid)
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
        await AlarmSupport.shared.addNextSnoozeAction(uuid: uuid)
        return .result()
    }
}

struct AlarmCompleteWakeupCheckIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Complete Wake-up Check"
    static var openAppWhenRun = false
    static var isDiscoverable = false
    
    @Parameter(title: "UUID")
    var uuid: String
    init(uuid: String) { self.uuid = uuid }
    init() { self.uuid = "" }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        await AlarmSupport.shared.completeWakeupCheck()
        return .result()
    }
}

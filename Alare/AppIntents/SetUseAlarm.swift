//
//  SetUseAlarm.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/25.
//

import AppIntents
import WidgetKit

struct SetUseAlarm: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "SetUseAlarm"
    static var title: LocalizedStringResource = "Set Use Alare's Alarm"
    static var description: LocalizedStringResource = "Turn Alare's Alarm On or Off."
    
    enum TurnOrToggle: String, AppEnum {
        case turn
        case toggle

        static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Operation")
        static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
            .turn: "Turn",
            .toggle: "Toggle"
        ]
    }

    @Parameter(title: "Operation", default: .turn)
        var toggle: TurnOrToggle?

    @Parameter(title: "State", default: true)
        var state: Bool
    
    static var parameterSummary: some ParameterSummary {
        When(\.$toggle, .equalTo, .turn) {
            Summary("\(\.$toggle) Alare's Alarm \(\.$state)")
        } otherwise: {
            Summary("\(\.$toggle) Alare's Alarm")
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let support = AlarmSupport.shared
        var settings = support.settings
        
        switch toggle {
        case .toggle:
            settings.isEnabled.toggle()
        case .turn:
            settings.isEnabled = state
        default:
            break
        }
        
        await support.push(settings)
        NotificationCenter.default.post(name: .alarmSettingsDidChangeOutsideMainApp, object: nil)
        
        return .result()
    }
}

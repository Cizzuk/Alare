//
//  SetWakeupAction.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/25.
//

import AppIntents
import WidgetKit

struct SetWakeupAction: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "SetWakeupAction"
    static var title: LocalizedStringResource = "Set Wake-up Action"
    static var description: LocalizedStringResource = "Set a Wake-up Action to stop the alarm."
    
    @Parameter(title: "Action", default: .tapButton)
    var action: WakeupAction
    
    static var parameterSummary: some ParameterSummary {
        Summary("Set Wake-up Action to \(\.$action)")
    }
    
    enum IntentError: LocalizedError {
        case actionUnavailable
        
        var errorDescription: String? {
            switch self {
            case .actionUnavailable:
                return String(localized: "The selected Wake-up Action is not available.")
            }
        }
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String?> {
        let waManager = WakeupActionManager.shared
        
        guard action.isAvailable() else {
            throw IntentError.actionUnavailable
        }
        
        waManager.settings.selected = action
        
        return .result(value: nil)
    }
}

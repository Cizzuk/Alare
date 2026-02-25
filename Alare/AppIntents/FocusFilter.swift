//
//  FocusFilter.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/25.
//

import AppIntents

struct FocusFilter : SetFocusFilterIntent {
    static var title: LocalizedStringResource = "Set Wake-up Action"
    static var description: LocalizedStringResource = "Sets a Wake-up Action to be used during this Focus."
    
    @Parameter(title: "Action", default: nil)
    var action: WakeupAction?
    
    var displayRepresentation: DisplayRepresentation {
        let subtitle = action?.displayName ?? "Not Set"
        return DisplayRepresentation(title: "Wake-up Action", subtitle: subtitle)
    }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

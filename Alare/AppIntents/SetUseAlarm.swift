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
    static var description: LocalizedStringResource = "Turn Alare's alarm On or Off."
    
    @Parameter(title: "Time")
    var date: Date?
    
//    static var parameterSummary: some ParameterSummary {
//        When(\.$toggle, .equalTo, .turn) {
//            Summary("\(\.$toggle) Alare's Alarm \(\.$state)")
//        } otherwise: {
//            Summary("\(\.$toggle) Alare's Alarm")
//        }
//    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        let support = AlarmSupport.shared
        var settings = support.settings
        
        
        
        await support.push(settings)
        NotificationCenter.default.post(name: .alarmSettingsDidChangeOutsideMainApp, object: nil)
        
        return .result()
    }
}

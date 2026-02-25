//
//  ControlCenterWidget.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/25.
//

import SwiftUI
import WidgetKit

struct StartWakeupActionControl: ControlWidget {
    static let kind = "net.cizzuk.alare.WidgetExtension.StartWakeupActionControl"
    static let title: LocalizedStringResource = StartWakeupActionIntent.title
    
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: StartWakeupActionControl.kind,
            provider: Provider()
        ) { value in
            ControlWidgetButton(
                "Alare",
                action: StartWakeupActionIntent()
            ) { _ in
                if value {
                    Label("Wake-up Action", image: "bolt.alare")
                } else {
                    Label("Open Alare", image: "alare")
                }
            }
        }
    }
    
    struct Provider: ControlValueProvider {
        var previewValue: Bool { false }
        func currentValue() async throws -> Bool {
            return RegisteredAlarms.load().nextSnooze != nil
        }
    }
}

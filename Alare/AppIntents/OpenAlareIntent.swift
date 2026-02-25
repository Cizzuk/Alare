//
//  OpenAlareIntent.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/25.
//

import AppIntents
import SwiftUI
import WidgetKit

struct OpenAlareIntent: AppIntent {
    static let title: LocalizedStringResource = "Alare"
    
    static var openAppWhenRun = true
    static var isDiscoverable = false

    @MainActor
    func perform() async throws -> some OpensIntent {
        return .result()
    }
}

struct OpenAlareControl: ControlWidget {
    static let kind = "net.cizzuk.alare.WidgetExtension.OpenAlareControl"
    static let title: LocalizedStringResource = OpenAlareIntent.title
    
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: OpenAlareControl.kind) {
            ControlWidgetButton(action: OpenAlareIntent()) {
                Label(OpenAlareControl.title, image: "alare")
            }
        }
        .displayName(OpenAlareControl.title)
    }
}

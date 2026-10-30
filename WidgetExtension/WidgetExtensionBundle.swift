//
//  WidgetExtensionBundle.swift
//  Alare Widget Extension
//
//  Created by Cizzuk on 2026/02/25.
//

import SwiftUI
import WidgetKit

@main
struct WidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        AlarmStateHomeWidget()
        AlarmStateLockWidget()
        StartWakeupActionControl()
        SnoozeActivityWidget()
    }
}

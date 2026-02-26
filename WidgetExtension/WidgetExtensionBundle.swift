//
//  WidgetExtensionBundle.swift
//  WidgetExtension
//
//  Created by Cizzuk on 2026/02/25.
//

import WidgetKit
import SwiftUI

@main
struct WidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        AlarmStateHomeWidget()
        AlarmStateLockWidget()
        StartWakeupActionControl()
    }
}

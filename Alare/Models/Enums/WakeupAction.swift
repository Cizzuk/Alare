//
//  WakeupAction.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/19.
//

import Foundation
import SwiftUI

enum WakeupAction: String, CaseIterable, Codable, Identifiable {
    case waveDevice
    case scanCode
    case drumRoll
    case tapButton
    
    static let `default` = tapButton
    
    var id: String { rawValue }
}

extension WakeupAction {
    var displayName: LocalizedStringResource {
        switch self {
        case .waveDevice:
            return "Wave Device"
        case .scanCode:
            return "Scan Code"
        case .drumRoll:
            return "Drum Roll"
        case .tapButton:
            return "Tap Button"
        }
    }
    
    var systemImage: String {
        switch self {
        case .waveDevice:
            return "flag"
        case .scanCode:
            return "qrcode.viewfinder"
        case .drumRoll:
            return "hand.tap"
        case .tapButton:
            return "button.programmable"
        }
    }
    
    var actionDescription: LocalizedStringResource {
        switch self {
        case .waveDevice:
            return "Wave the device slowly and broadly like a flag."
        case .scanCode:
            return "Scan the code placed outside the bed."
        case .drumRoll:
            return "Drum roll your fingers on the screen."
        case .tapButton:
            return "Just tap the button once."
        }
    }

    func isAvailable(settings: WakeupActionSettings) -> Bool {
        switch self {
        case .waveDevice:
            return false
        case .scanCode:
            return false
            // TODO: Add checker for camera permission
//            return settings.scanCode_code != nil
        case .drumRoll, .tapButton:
            return true
        }
    }

    @ViewBuilder
    func settingsView(manager: WakeupActionManager) -> some View {
        switch self {
        case .waveDevice:
            EmptyView()
        case .scanCode:
            ScanCodeWakeupActionSettingsView(manager: manager)
        case .drumRoll:
            DrumRollWakeupActionSettingsView(manager: manager)
        case .tapButton:
            EmptyView()
        }
    }

    @ViewBuilder
    func executionView(vm: WakeupActionExecutionViewModel) -> some View {
        switch self {
        case .waveDevice:
            WaveDeviceWakeupActionExecutionView(vm: vm)
        case .scanCode:
            ScanCodeWakeupActionExecutionView(vm: vm)
        case .drumRoll:
            DrumRollWakeupActionExecutionView(vm: vm)
        case .tapButton:
            TapButtonWakeupActionExecutionView(vm: vm)
        }
    }
    
}

//
//  WakeupAction.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/19.
//

import AppIntents
import AVFoundation
import CoreMotion
import SwiftUI

enum WakeupAction: String, CaseIterable, Codable, Identifiable, AppEnum {
    case waveDevice
    case scanCode
    case drumRoll
    case tapButton
    
    static let `default` = tapButton
    
    var id: String { rawValue }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Wake-up Action")
    }
    
    static var caseDisplayRepresentations: [WakeupAction : DisplayRepresentation] = [
        .waveDevice: DisplayRepresentation(title: "Wave Device"),
        .scanCode: DisplayRepresentation(title: "Scan Code"),
        .drumRoll: DisplayRepresentation(title: "Drum Roll"),
        .tapButton: DisplayRepresentation(title: "Tap Button")
    ]
}

extension WakeupAction {
    var displayName: LocalizedStringResource {
        return Self.caseDisplayRepresentations[self]?.title ?? ""
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

    @MainActor
    func isAvailable() -> Bool {
        let settings = WakeupActionManager.shared.settings
        switch self {
        case .waveDevice:
            return CMMotionManager().isDeviceMotionAvailable
        case .scanCode:
            if settings.scanCode_code == nil {
                return false
            }
            
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized, .notDetermined:
                break
            default:
                return false
            }
            
            return true
        case .drumRoll, .tapButton:
            return true
        }
    }

    @ViewBuilder
    func settingsView() -> some View {
        switch self {
        case .waveDevice:
            WaveDeviceWakeupActionSettingsView()
        case .scanCode:
            ScanCodeWakeupActionSettingsView()
        case .drumRoll:
            DrumRollWakeupActionSettingsView()
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

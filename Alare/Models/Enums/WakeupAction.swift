//
//  WakeupAction.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/19.
//

import Foundation

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
    
    var isAvailable: Bool {
        switch self {
        case .waveDevice, .scanCode:
            return false
        case .drumRoll, .tapButton:
            return true
        }
    }
}

//
//  WakeupAction.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/19.
//

import Foundation

enum WakeupAction: String, CaseIterable, Codable {
    case waveDevice
    case scanCode
    case drumRoll
    case tapButton
    
    static let `default` = tapButton
    
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
            return "flag.pattern.checkered.2.crossed"
        case .scanCode:
            return "qrcode.viewfinder"
        case .drumRoll:
            return "hand.tap"
        case .tapButton:
            return "button.horizontal.top.press"
        }
    }
}

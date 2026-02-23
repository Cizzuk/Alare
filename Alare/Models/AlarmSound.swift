//
//  AlarmSound.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/19.
//

import ActivityKit
import Foundation

enum AlarmSound: String, CaseIterable, Codable {
    case hailing
    case sysDefault
    
    static let `default` = hailing
    
    var displayName: LocalizedStringResource {
        switch self {
        case .hailing:
            return "Hailing"
        case .sysDefault:
            return "System Default"
        }
    }
    
    var alertSound: AlertConfiguration.AlertSound {
        switch self {
        case .hailing:
            return .default
        case .sysDefault:
            return .default
        }
    }
}

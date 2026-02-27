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
    case attention
    case sysDefault
    case custom
    
    static let `default` = hailing
}

extension AlarmSound {
    var displayName: LocalizedStringResource {
        switch self {
        case .hailing:
            return "Hailing"
        case .attention:
            return "Attention"
        case .sysDefault:
            return "System Default"
        case .custom:
            return "Custom"
        }
    }
    
    var alertSound: AlertConfiguration.AlertSound {
        switch self {
        case .hailing:
            return .named("Hailing.m4a")
        case .attention:
            return .named("Attention.m4a")
        case .sysDefault:
            return .default
        case .custom:
            guard let soundURL = Self.customSoundFileURL() else { return .default }
            return .named("CustomSound/\(soundURL.lastPathComponent)")
        }
    }
    
    var alertSoundSnooze: AlertConfiguration.AlertSound {
        switch self {
        case .hailing:
            return .named("Hailing-Snooze.m4a")
        case .attention:
            return .named("Attention-Snooze.m4a")
        default:
            return self.alertSound
        }
    }
    
    static var customSoundDir: URL {
        FileManager.default
            .urls(for: .libraryDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("Sounds/CustomSound")
    }

    static func customSoundFileURL() -> URL? {
        try? FileManager.default
            .contentsOfDirectory(at: customSoundDir, includingPropertiesForKeys: nil)
            .first
    }
}

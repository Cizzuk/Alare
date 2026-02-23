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
    case custom
    
    static let `default` = hailing
    
    var displayName: LocalizedStringResource {
        switch self {
        case .hailing:
            return "Hailing"
        case .sysDefault:
            return "System Default"
        case .custom:
            return "Custom"
        }
    }
    
    var alertSound: AlertConfiguration.AlertSound {
        switch self {
        case .hailing:
            return .default
        case .sysDefault:
            return .default
        case .custom:
            guard let soundURL = Self.customSoundFileURL() else { return .default }
            return .named("CustomSound/\(soundURL.lastPathComponent)")
        }
    }
    
    private static var customSoundDir: URL {
        FileManager.default
            .urls(for: .libraryDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("Sounds/CustomSound")
    }

    private static func customSoundFileURL() -> URL? {
        try? FileManager.default
            .contentsOfDirectory(at: customSoundDir, includingPropertiesForKeys: nil)
            .first
    }
    
    static func importCustomSound(from url: URL) -> Bool {
        guard url.startAccessingSecurityScopedResource() else { return false }
        defer { url.stopAccessingSecurityScopedResource() }

        let fileManager = FileManager.default
        let destinationURL = customSoundDir.appendingPathComponent(url.lastPathComponent)

        do {
            try fileManager.createDirectory(at: customSoundDir, withIntermediateDirectories: true)

            // Clear custom sound directory
            let existingFiles = try fileManager.contentsOfDirectory(
                at: customSoundDir,
                includingPropertiesForKeys: nil
            )
            for fileURL in existingFiles {
                try fileManager.removeItem(at: fileURL)
            }

            // Copy new custom sound
            try fileManager.copyItem(at: url, to: destinationURL)
            
            // Sync alarm
            Task { await AlarmSupport.shared.sync() }
            return true
        } catch {
            return false
        }
    }
}

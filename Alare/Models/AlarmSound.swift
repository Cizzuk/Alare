//
//  AlarmSound.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/19.
//

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
}

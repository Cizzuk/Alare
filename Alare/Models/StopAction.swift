//
//  StopAction.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/19.
//

import Foundation

enum StopAction: String, CaseIterable, Codable {
    case tapButton
    
    static let `default` = tapButton
    
    var displayName: LocalizedStringResource {
        switch self {
        case .tapButton:
            return "Tap Button"
        }
    }
}

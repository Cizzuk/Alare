//
//  WakeupActionSettings.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/23.
//

import Foundation

struct WakeupActionSettings: Codable {
    static let userDefaultsKey = "WakeupActionSettings"
    
    var selected: WakeupAction = .default
    var relaxationMode: Bool = false
}

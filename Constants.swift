//
//  Constants.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/23.
//

import Foundation
import SwiftUI

let userDefaults = UserDefaults(suiteName: "group.net.cizzuk.alare")!

let NightGradient = LinearGradient(
    gradient: Gradient(colors: [.dropblue.opacity(0.2), .black]),
    startPoint: .top,
    endPoint: .bottom
)

// NotificationCenter Names
extension Notification.Name {
    static let shouldStartWakeupAction = Notification.Name("shouldStartWakeupAction")
}

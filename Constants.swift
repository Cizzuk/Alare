//
//  Constants.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/23.
//

import SwiftUI

let userDefaults = UserDefaults(suiteName: "group.net.cizzuk.alare")!

let completeWakeupActionURL = "https://cizz.uk/alare/sc"

let NightGradient = LinearGradient(
    gradient: Gradient(colors: [.dropblue.opacity(0.2), .black]),
    startPoint: .top,
    endPoint: .bottom
)

// NotificationCenter Names
extension Notification.Name {
    static let shouldStartWakeupAction = Notification.Name("shouldStartWakeupAction")
    static let alarmSettingsDidChangeOutsideMainApp = Notification.Name("alarmSettingsDidChangeOutsideMainApp")
    static let focusFilterDidChange = Notification.Name("focusFilterDidChange")
}

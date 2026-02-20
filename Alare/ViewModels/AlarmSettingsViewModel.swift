//
//  AlarmSettingsViewModel.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/20.
//

import Combine
import SwiftUI

class AlarmSettingsViewModel: ObservableObject {
    @Published var draft: AlarmData = AlarmManager.shared.alarm
    
    func save() {
        Task {
            await AlarmManager.shared.update(draft)
        }
    }
}

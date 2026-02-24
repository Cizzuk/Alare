//
//  WakeupActionSettingsViewModel.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/24.
//

import Combine
import SwiftUI

class WakeupActionSettingsViewModel: ObservableObject {
    @ObservationIgnored private var manager = WakeupActionManager.shared
}

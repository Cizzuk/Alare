//
//  MainViewModel.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/19.
//

import Combine
import SwiftUI

class MainViewModel: ObservableObject {
    private var alarm = AlarmSupport.shared
    
    @Published var draft: AlarmData = AlarmData() {
        didSet {
            Task { await alarm.update(draft) }
        }
    }
}

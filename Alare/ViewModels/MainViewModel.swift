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
    
    @Published var draft: AlarmSettings = AlarmSettings() {
        didSet {
            // Date validation
            let next = AlarmSupport.cutSeconds(draft.next)
            let now = AlarmSupport.cutSeconds(Date())
            if next <= now {
                // Add 1 day
                draft.next = Calendar.current.date(byAdding: .day, value: 1, to: draft.next) ?? draft.next
            }
            
            // Update
            Task { await alarm.update(draft) }
        }
    }
}

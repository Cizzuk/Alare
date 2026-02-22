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
    
    @Published var draft: AlarmSettings = AlarmSupport.shared.settings {
        didSet {
            // Push changes
            Task {
                if draft != alarm.settings {
                    await alarm.push(draft)
                    syncDraft()
                }
            }
        }
    }
    
    func onChange(scenePhase: ScenePhase) {
        switch scenePhase {
        case .active:
            syncDraft()
        case .inactive:
            break
        case .background:
            break
        @unknown default:
            break
        }
    }
    
    func syncDraft() {
        if alarm.settings != draft {
            draft = alarm.settings
        }
    }
    
    func stopAlarm() {
        alarm.stop()
        syncDraft()
    }
}

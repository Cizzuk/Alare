//
//  MainViewModel.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/19.
//

import Combine
import SwiftUI

class MainViewModel: ObservableObject {
    @ObservationIgnored private var support = AlarmSupport.shared
    
    @Published var draft: AlarmSettings = AlarmSupport.shared.settings {
        didSet {
            // Push changes
            Task {
                if draft != support.settings {
                    await support.push(draft)
                    syncDraft()
                }
            }
        }
    }
    
    func onChange(scenePhase: ScenePhase) {
        switch scenePhase {
        case .active:
            Task {
                await support.validate()
                syncDraft()
            }
        case .inactive:
            break
        case .background:
            break
        @unknown default:
            break
        }
    }
    
    func syncDraft() {
        if support.settings != draft {
            draft = support.settings
        }
    }
    
    func killAlarm() {
        Task {
            await support.kill()
            syncDraft()
        }
    }
}

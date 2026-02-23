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
    
    @Published var timeSelection: Date = makeDateFromTime(
        hour: AlarmSupport.shared.settings.hour,
        minute: AlarmSupport.shared.settings.minute
    ) {
        didSet {
            // Convert Date to hour and minute
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: timeSelection)
            let hour = components.hour ?? draft.hour
            let minute = components.minute ?? draft.minute
            // Update draft
            if draft.hour != hour || draft.minute != minute {
                draft.hour = hour
                draft.minute = minute
            }
        }
    }
    
    // Create Date from hour and minute
    private static func makeDateFromTime(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        let base = calendar.startOfDay(for: Date())
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: base) ?? base
    }
    
    // MARK: - Public Methods
    
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
        
        // Sync timeSelection
        let date = Self.makeDateFromTime(hour: draft.hour, minute: draft.minute)
        timeSelection = date
    }
    
    func killAlarm() {
        Task {
            await support.kill()
            syncDraft()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
    
    func importCustomSound(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first,
               AlarmSound.importCustomSound(from: url) {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        case .failure(let error):
            print("Custom sound file import error: ", error)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}

//
//  MainViewModel.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/19.
//

import AppIntents
import Combine
import SwiftUI

class MainViewModel: ObservableObject {
    @ObservationIgnored private var register = AlarmRegister.shared
    @ObservationIgnored private var support = AlarmSupport.shared
    @ObservationIgnored private var waManager = WakeupActionManager.shared
    
    @Published var doingWakeupAction: WakeupAction? = nil
    var focusFilterWakeupAction: WakeupAction? = nil
    
    @Published var draft: AlarmSettings = AlarmSupport.shared.settings {
        didSet {
            // Push changes
            Task {
                if support.settings != draft {
                    await support.push(draft)
                    syncDraft()
                }
            }
        }
    }
    
    @Published var timeSelection: Date = AlarmSupport.makeDateFromTime(
        hour: AlarmSupport.shared.settings.hour,
        minute: AlarmSupport.shared.settings.minute
    ) {
        didSet {
            // Convert Date to hour and minute
            let (hour, minute) = AlarmSupport.makeTimeFromDate(timeSelection)
            // Update draft
            if draft.hour != hour || draft.minute != minute {
                draft.hour = hour
                draft.minute = minute
            }
        }
    }
    
    // MARK: - Lifecycle
    
    func onAppear() {
        syncAll()
    }
    
    func onChange(scenePhase: ScenePhase) {
        switch scenePhase {
        case .active:
            syncAll()
        case .inactive:
            break
        case .background:
            break
        @unknown default:
            break
        }
    }
    
    func handleOpenURL(url: URL) {
        // Get App URL Schemes
        let appURLSchemes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]]
        let urlSchemes = appURLSchemes?.compactMap { $0["CFBundleURLSchemes"] as? [String] }.flatMap { $0 } ?? []
        
        // Check URL Scheme
        guard let scheme = url.scheme,
              urlSchemes.contains(scheme)
        else { return }
        
        // Parse URL
        switch url.host {
        case "wakeupaction":
            startWakeupAction()
        default:
            break
        }
    }
    
    // MARK: - Alarm Management
    
    func syncAll() {
        // Sync now
        Task {
            await support.validate()
            syncDraft()
        }
        
        // Sync in background
        DispatchQueue.global(qos: .utility).async {
            self.waManager.validate()
            self.syncFocusFilter()
        }
    }
    
    func syncDraft() {
        if draft != support.settings {
            draft = support.settings
        }
        
        // Sync timeSelection
        let date = AlarmSupport.makeDateFromTime(hour: draft.hour, minute: draft.minute)
        timeSelection = date
    }
    
    func startWakeupAction() {
        // Check if alarm is snoozed and action is not already doing
        guard register.registereds.nextSnooze != nil,
              doingWakeupAction == nil
        else { return }
        
        // Start action
        if let focusFilterWakeupAction = focusFilterWakeupAction,
           focusFilterWakeupAction.isAvailable() {
            doingWakeupAction = focusFilterWakeupAction
        } else if waManager.settings.selected.isAvailable() {
            doingWakeupAction = waManager.settings.selected
        }
    }
    
    func completeWakeupAction() {
        killAlarm()
        doingWakeupAction = nil
        HapticManager.shared.playHaptics(.success)
    }
    
    func killAlarm() {
        Task {
            await support.kill()
            syncDraft()
        }
    }
    
    // MARK: - Custom Sound
    
    func importCustomSoundHandler(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first,
               importCustomSoundFile(from: url) {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        case .failure(let error):
            print("Custom sound file import error: ", error)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    
    func importCustomSoundFile(from url: URL) -> Bool {
        guard url.startAccessingSecurityScopedResource() else { return false }
        defer { url.stopAccessingSecurityScopedResource() }

        let fileManager = FileManager.default
        let customSoundDir = AlarmSound.customSoundDir
        let destinationURL = customSoundDir.appendingPathComponent(url.lastPathComponent)

        do {
            try fileManager.createDirectory(at: customSoundDir, withIntermediateDirectories: true)

            // Clear custom sound directory
            let existingFiles = try fileManager.contentsOfDirectory(
                at: customSoundDir,
                includingPropertiesForKeys: nil
            )
            for fileURL in existingFiles {
                try fileManager.removeItem(at: fileURL)
            }

            // Copy new custom sound
            try fileManager.copyItem(at: url, to: destinationURL)
            
            // Sync alarm
            Task { await AlarmSupport.shared.sync() }
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - Focus Filter
    
    func syncFocusFilter() {
        Task {
            focusFilterWakeupAction = nil
            do {
                let filter: FocusFilterIntent = try await FocusFilterIntent.current
                focusFilterWakeupAction = filter.action
            } catch {
                focusFilterWakeupAction = nil
                print("Failed to fetch focus filter: ", error)
            }
        }
    }
}

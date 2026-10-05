//
//  SnoozeActivity.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/26.
//

import ActivityKit
import Foundation

nonisolated struct SnoozeActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var snoozeCount: Int
    }
}

class SnoozeActivityManager {
    static func isActive() -> Bool {
        return !Activity<SnoozeActivityAttributes>.activities.isEmpty
    }
    
    private static func makeContentState() -> SnoozeActivityAttributes.ContentState {
        return SnoozeActivityAttributes.ContentState(
            snoozeCount: RegisteredAlarms.load().snoozeCount
        )
    }
    
    static func start(endDate: Date? = nil) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Activities are not enabled. Cannot start snooze activity.")
            return
        }
        endAll()
        
        let content = ActivityContent(
            state: makeContentState(),
            staleDate: endDate
        )
        
        do {
            let _ = try Activity.request(
                attributes: SnoozeActivityAttributes(),
                content: content,
                pushType: nil
            )
        } catch {
            print("Failed to start snooze activity: \(error)")
        }
    }
    
    static func update() {
        let activities = Activity<SnoozeActivityAttributes>.activities
        
        let content = ActivityContent(
            state: makeContentState(),
            staleDate: nil
        )
        
        Task {
            for activity in activities {
                await activity.update(content)
            }
        }
    }
    
    static func endAll() {
        let activities = Activity<SnoozeActivityAttributes>.activities
        
        let semaphore = DispatchSemaphore(value: 0)
        Task.detached(priority: .userInitiated) {
            for activity in activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            semaphore.signal()
        }
        semaphore.wait()
    }
}

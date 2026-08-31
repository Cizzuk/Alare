//
//  SnoozeActivity.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/26.
//

import ActivityKit
import Foundation

struct SnoozeActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable { }
}

class SnoozeActivityManager {
    static func isActive() -> Bool {
        return !Activity<SnoozeActivityAttributes>.activities.isEmpty
    }
    
    static func start(endDate: Date? = nil) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Activities are not enabled. Cannot start snooze activity.")
            return
        }
        endAll()
        
        let attributes = SnoozeActivityAttributes()
        
        let contentState = SnoozeActivityAttributes.ContentState()
        
        let content = ActivityContent(
            state: contentState,
            staleDate: endDate
        )
        
        do {
            let _ = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            print("Failed to start snooze activity: \(error)")
        }
    }
    
    static func endAll() {
        let activities = Activity<SnoozeActivityAttributes>.activities
        
        let contentState = SnoozeActivityAttributes.ContentState()
        
        let content = ActivityContent(
            state: contentState,
            staleDate: nil
        )
        
        let semaphore = DispatchSemaphore(value: 0)
        Task.detached(priority: .userInitiated) {
            for activity in activities {
                await activity.end(content, dismissalPolicy: .immediate)
            }
            semaphore.signal()
        }
        semaphore.wait()
    }
}

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
            let activity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            print("Started snooze activity: \(activity)")
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
        
        for activity in activities {
            Task {
                await activity.end(
                    content,
                    dismissalPolicy: .immediate
                )
            }
            print("Ended snooze activity: \(activity)")
        }
    }
}

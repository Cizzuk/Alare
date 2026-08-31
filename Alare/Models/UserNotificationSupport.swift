//
//  UserNotificationSupport.swift
//  Alare
//
//  Created by Cizzuk on 2026/08/31.
//

import UserNotifications

class UserNotificationSupport {
    static func authorizationStatus() async -> UNAuthorizationStatus {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }
    
    static func isAvailable() async -> Bool {
        let authorizationStatus = await authorizationStatus()
        
        if authorizationStatus == .notDetermined || authorizationStatus == .authorized {
            return true
        }
        
        return false
    }
    
    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        if settings.authorizationStatus == .notDetermined {
            do {
                try await center.requestAuthorization(options: [.alert])
                return await requestAuthorization()
            } catch {
                print("Failed to request notification authorization: \(error)")
                return false
            }
        }

        if settings.authorizationStatus == .authorized {
            return true
        }

        return false
    }
    
    static func sendNotification(
        _ content: UNMutableNotificationContent,
        trigger: UNNotificationTrigger? = nil
    ) async {
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        do {
            try await notificationCenter.add(request)
        } catch {
            print("Failed to add notification request: \(error)")
        }
    }
}

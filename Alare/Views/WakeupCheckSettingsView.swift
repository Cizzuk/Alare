//
//  WakeupCheckSettingsView.swift
//  Alare
//
//  Created by Cizzuk on 2026/08/31.
//

import SwiftUI

struct WakeupCheckSettingsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var manager = WakeupCheckManager.shared
    
    @State private var showStartAfterPicker = false
    private let startAfterIntList = Array(1...30)
    
    @State private var showAlarmAfterPicker = false
    private let alarmAfterIntList = Array(1...30)
    
    @State private var showNotificationPermissionAlert = false
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 5) {
                    Image("bolt.alare")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .accessibilityHidden(true)
                        .padding(.bottom, 10)
                        .foregroundStyle(.accent)
                    Text("Wake-up Check (Beta)")
                        .font(.title2)
                        .bold()
                        .accessibilityAddTraits(.isHeader)
                    Text("After the Wake-up Action is completed, a notification will be sent to confirm whether you have actually woken up. If there is no response to the notification, the alarm will play again.")
                        .foregroundStyle(.secondary)
                }
                
                Toggle("Wake-up Check", isOn: $manager.settings.isEnabled)
                    .tint(.accent)
                    .onChange(of: manager.settings.isEnabled) {
                        if manager.settings.isEnabled {
                            Task { showNotificationPermissionAlert = await !UserNotificationSupport.requestAuthorization() }
                        }
                    }
            } footer: {
                if showNotificationPermissionAlert {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Notifications are not allowed. Wake-up Check notifications will not be sent.")
                        if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                            Button(action: { UIApplication.shared.open(url) }) {
                                Text("Open Settings...")
                            }
                        }
                    }
                    .font(.footnote)
                }
            }
            .task {
                showNotificationPermissionAlert = await !UserNotificationSupport.isAvailable()
            }
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    Task { showNotificationPermissionAlert = await !UserNotificationSupport.isAvailable() }
                }
            }
            
            Section {
                HStack {
                    Text("Send Notification After")
                    Spacer()
                    Button(action: { withAnimation { showStartAfterPicker.toggle() } }) {
                        Text("\(manager.settings.startAfter) min")
                            .font(.default.monospacedDigit())
                    }
                }
                
                if showStartAfterPicker {
                    Picker("Send Notification After", selection: $manager.settings.startAfter) {
                        ForEach(startAfterIntList, id: \.self) { startAfter in
                            Text("\(startAfter) min").tag(startAfter)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                
                HStack {
                    Text("Ring Alarm After")
                    Spacer()
                    Button(action: { withAnimation { showAlarmAfterPicker.toggle() } }) {
                        Text("\(manager.settings.alarmAfter) min")
                            .font(.default.monospacedDigit())
                    }
                }
                
                if showAlarmAfterPicker {
                    Picker("Ring Alarm After", selection: $manager.settings.alarmAfter) {
                        ForEach(alarmAfterIntList, id: \.self) { alarmAfter in
                            Text("\(alarmAfter) min").tag(alarmAfter)
                        }
                    }
                    .pickerStyle(.wheel)
                }
            }
        }
        .navigationTitle("Wake-up Check")
        .navigationBarTitleDisplayMode(.inline)
    }
}

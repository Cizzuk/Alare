//
//  WakeupCheckSettingsView.swift
//  Alare
//
//  Created by Cizzuk on 2026/08/31.
//

import SwiftUI

struct WakeupCheckSettingsView: View {
    @StateObject private var manager = WakeupCheckManager.shared
    
    @State private var showStartAfterPicker = false
    private let startAfterIntList = Array(1...30)
    
    @State private var showAlarmAfterPicker = false
    private let alarmAfterIntList = Array(1...30)
    
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

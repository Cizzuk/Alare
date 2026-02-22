//
//  MainView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/18.
//

import AlarmKit
import SwiftUI

struct MainView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var register = AlarmRegister.shared
    @StateObject private var vm = MainViewModel()

    var body: some View {
        NavigationStack {
            List {
                if register.registereds.nextSnooze != nil {
                    Section("You are currently snoozing!") {
                        Button(action: { vm.killAlarm() }) {
                            Label("Stop the alarm completely", systemImage: "stop.circle")
                        }
                    }
                }
                
                Section {
                    DatePicker("Time", selection: $vm.timeSelection, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                    
                    Toggle("Turn on Alarm", isOn: $vm.draft.isEnabled)
                        .disabled(AlarmManager.shared.authorizationState == .denied)
                } footer: {
                    if AlarmManager.shared.authorizationState == .denied {
                        Text("Alarm permission is not granted. Please enable it in Settings to use the Alare.")
                    }
                }
                
                Section("Repeat") {
                    WeekdaysView(repeats: $vm.draft.repeats)
                }
                
                Section("Options") {
                    Stepper(value: $vm.draft.snoozeInterval, in: 1...15) {
                        HStack {
                            Text("Snooze Duration")
                            Spacer()
                            Text("\(vm.draft.snoozeInterval)m")
                                .font(.default.monospacedDigit())
                        }
                    }
                    .onChange(of: vm.draft.snoozeInterval) {
                        UISelectionFeedbackGenerator().selectionChanged()
                    }
                    
//                    Picker("Sound", selection: $vm.draft.sound) {
//                        ForEach(AlarmSound.allCases, id: \.self) { sound in
//                            Text(sound.displayName).tag(sound)
//                        }
//                    }
                }
                
                Section {
                    NavigationLink(destination: AboutView()) {
                        Label("About", systemImage: "info.circle")
                            .foregroundColor(.primary)
                    }
                    if UIApplication.shared.supportsAlternateIcons {
                        NavigationLink(destination: ChangeIconView()) {
                            Label("Change App Icon", systemImage: "app.dashed")
                                .foregroundColor(.primary)
                        }
                    }
                }
            } // List
            .navigationTitle("Alare")
        } // NavigationStack
        // MARK: - Events
        .onChange(of: scenePhase) { vm.onChange(scenePhase: scenePhase) }
    }
}

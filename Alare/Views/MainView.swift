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
    
    @StateObject private var support = AlarmSupport.shared
    @StateObject private var register = AlarmRegister.shared
    @StateObject private var vm = MainViewModel()
    
    @State private var showChangeIconView = false
    
    // Pseudo loop
    let hourArray = Array(repeating: Array(0...23), count: 11).flatMap { $0 }
    let minuteArray = Array(repeating: Array(0...59), count: 11).flatMap { $0 }
    
    @State private var hourSelectionIndex: Int = 9
    @State private var minuteSelectionIndex: Int = 0
    
    func syncTimeSelection() {
        hourSelectionIndex = vm.draft.hour + 24 * 5
        minuteSelectionIndex = vm.draft.minute + 60 * 5
    }
    
    func applyTimeChange() {
        vm.draft.hour = hourArray[hourSelectionIndex]
        vm.draft.minute = minuteArray[minuteSelectionIndex]
        syncTimeSelection()
    }

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
                    HStack {
                        Picker("Hour", selection: $hourSelectionIndex) {
                            ForEach(hourArray.indices, id: \.self) { index in
                                Text("\(hourArray[index])").tag(index)
                            }
                        }
                        .onChange(of: hourSelectionIndex) { applyTimeChange() }
                        
                        Picker("Minute", selection: $minuteSelectionIndex) {
                            ForEach(minuteArray.indices, id: \.self) { index in
                                Text("\(minuteArray[index])").tag(index)
                            }
                        }
                        .onChange(of: minuteSelectionIndex) { applyTimeChange() }
                    }
                    .onAppear { syncTimeSelection() }
                    .onChange(of: support.settings) { syncTimeSelection() }
                    .pickerStyle(.wheel)
                    
                    Toggle("Enabled", isOn: $vm.draft.isEnabled)
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
                    
//                    Picker("Sound", selection: $vm.draft.sound) {
//                        ForEach(AlarmSound.allCases, id: \.self) { sound in
//                            Text(sound.displayName).tag(sound)
//                        }
//                    }
                }
                
                if UIApplication.shared.supportsAlternateIcons {
                    Section {
                        Button(action: { showChangeIconView = true }) {
                            Label("Change App Icon", systemImage: "app.dashed")
                        }
                    }
                }
            } // List
            .navigationTitle("Alare")
        } // NavigationStack
        .sheet(isPresented: $showChangeIconView) { ChangeIconView() }
        // MARK: - Events
        .onChange(of: scenePhase) { vm.onChange(scenePhase: scenePhase) }
    }
}

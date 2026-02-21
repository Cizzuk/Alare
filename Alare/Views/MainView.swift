//
//  MainView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/18.
//

import SwiftUI

struct MainView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var alarm = AlarmSupport.shared
    @StateObject private var vm = MainViewModel()
    
    @State private var showChangeIconView = false

    var body: some View {
        NavigationStack {
            List {
                if let nextAlarm = alarm.session.registeredAlarmDate {
                    Section {} footer: {
                        Text("Next Alarm: \(nextAlarm.formatted(date: .abbreviated, time: .shortened))")
                    }
                }
                
                if alarm.session.isSnoozing {
                    Section("You are currently snoozing!") {
                        Button(action: { vm.stopAlarm() }) {
                            Label("Stop the alarm completely", systemImage: "stop.circle")
                        }
                    }
                }
                
                Section {
                    Toggle("Enabled", isOn: $vm.draft.isEnabled)
                    DatePicker(
                        "Next Alarm",
                        selection: $vm.draft.next,
                        in: Date().addingTimeInterval(1 * 60)...,
                    )
                }
                
//                Section("Repeat") {
//                    
//                }
                
                Section("Options") {
                    Stepper(value: $vm.draft.snoozeIntervalMinutes, in: 1...15) {
                        Text("Snooze Duration: \(vm.draft.snoozeIntervalMinutes)m")
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

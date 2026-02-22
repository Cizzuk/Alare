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
    
    let hourArray = Array(0...23)
    let minuteArray = Array(0...59)

    var body: some View {
        NavigationStack {
            List {
                if alarm.register.registereds.nextSnooze != nil {
                    Section("You are currently snoozing!") {
                        Button(action: { vm.killAlarm() }) {
                            Label("Stop the alarm completely", systemImage: "stop.circle")
                        }
                    }
                }
                
                Section {
                    Toggle("Enabled", isOn: $vm.draft.isEnabled)
                    HStack {
                        Picker("Hour", selection: $vm.draft.hour) {
                            ForEach(hourArray, id: \.self) { hour in
                                Text(String(format: "%02d", hour)).tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        Picker("Minute", selection: $vm.draft.minute) {
                            ForEach(minuteArray, id: \.self) { minute in
                                Text(String(format: "%02d", minute)).tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                }
                
                Section("Repeat") {
                    
                }
                
                Section("Options") {
                    Stepper(value: $vm.draft.snoozeInterval, in: 1...15) {
                        Text("Snooze Duration: \(vm.draft.snoozeInterval)m")
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

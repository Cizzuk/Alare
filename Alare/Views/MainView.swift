//
//  MainView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/18.
//

import SwiftUI

struct MainView: View {
    @StateObject private var alarm = AlarmSupport.shared
    @StateObject private var vm = MainViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Enabled", isOn: $vm.draft.isEnabled)
                    DatePicker(
                        "Next Alarm",
                        selection: $vm.draft.next,
                        in: Date()...,
                    )
                }
                
                Section("Repeat") {
                    
                }
                
                Section("Options") {
                    Stepper(value: $vm.draft.snoozeIntervalMinutes, in: 1...15) {
                        Text("Snooze Duration: \(vm.draft.snoozeIntervalMinutes)m")
                    }
                    
                    Picker("Sound", selection: $vm.draft.sound) {
                        ForEach(AlarmSound.allCases, id: \.self) { sound in
                            Text(sound.displayName).tag(sound)
                        }
                    }
                }
            }
            .navigationTitle("Alare")
        }
    }
}

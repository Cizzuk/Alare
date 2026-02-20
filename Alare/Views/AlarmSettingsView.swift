//
//  AlarmSettingsView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/20.
//

import SwiftUI

struct AlarmSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = AlarmSettingsViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Enabled", isOn: $viewModel.draft.isEnabled)
                    DatePicker("Next Alarm",
                               selection: $viewModel.draft.next)
                }
                
                Section("Repeat") {
                    
                }
                
                Section("Options") {
                    Stepper(value: $viewModel.draft.snoozeIntervalMinutes, in: 5...15) {
                        Text("Snooze Duration: \(viewModel.draft.snoozeIntervalMinutes)m")
                    }
                    
                    Picker("Sound", selection: $viewModel.draft.sound) {
                        ForEach(AlarmSound.allCases, id: \.self) { sound in
                            Text(sound.displayName).tag(sound)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { viewModel.save() }) {
                        Label("Done", systemImage: "checkmark")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Label("Cancel", systemImage: "xmark")
                    }
                }
            }
        }
    }
}

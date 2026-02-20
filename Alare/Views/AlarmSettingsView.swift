//
//  AlarmSettingsView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/20.
//

import SwiftUI

struct AlarmSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var alarm = AlarmManager.shared
    @State var draft: AlarmData = AlarmManager.shared.alarm
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Enabled", isOn: $draft.isEnabled)
                    DatePicker("Next Alarm",
                               selection: $draft.next,
                               in: Date()...)
                }
                
                Section("Repeat") {
                    
                }
                
                Section("Options") {
                    Stepper(value: $draft.snoozeIntervalMinutes, in: 5...15) {
                        Text("Snooze Duration: \(draft.snoozeIntervalMinutes)m")
                    }
                    
                    Picker("Sound", selection: $draft.sound) {
                        ForEach(AlarmSound.allCases, id: \.self) { sound in
                            Text(sound.displayName).tag(sound)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await alarm.update(draft)
                            dismiss()
                        }
                    } label: {
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

//
//  WakeupCheckSettingsView.swift
//  Alare
//
//  Created by Cizzuk on 2026/08/31.
//

import SwiftUI

struct WakeupCheckSettingsView: View {
    @StateObject private var manager = WakeupCheckManager.shared
    
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
                    Text("Wake-up Check")
                        .font(.title2)
                        .bold()
                        .accessibilityAddTraits(.isHeader)
                    Text("After the Wake-up Action is completed, a notification will be sent to confirm whether you have actually woken up. If there is no response to the notification, the alarm will play again.")
                        .foregroundStyle(.secondary)
                }
                
                Toggle("Wake-up Check", isOn: $manager.settings.isEnabled)
                    .tint(.accent)
            }
        }
        .navigationTitle("Wake-up Check")
        .navigationBarTitleDisplayMode(.inline)
    }
}

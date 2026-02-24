//
//  WakeupActionSettingsView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/23.
//

import SwiftUI

struct WakeupActionSettingsView: View {
    @StateObject private var manager = WakeupActionManager.shared
    @StateObject private var vm = WakeupActionSettingsViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 5) {
                        Image("bolt.alare")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .accessibilityHidden(true)
                            .padding(.bottom, 10)
                            .foregroundStyle(.accent)
                        Text("Wake-up Action")
                            .font(.title2)
                            .bold()
                            .accessibilityAddTraits(.isHeader)
                        Text("Alare's alarm will continue to snooze until you perform a Wake-up Action. To prevent oversleeping, select an action in advance that you believe will wake you up.")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Actions") {
                    ForEach(WakeupAction.allCases, id: \.self) { action in
                        // TODO: - Create action settings view
                        NavigationLink(destination: EmptyView()) {
                            HStack(spacing: 15) {
                                Image(systemName: action.systemImage)
                                    .font(.title)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40)
                                    .accessibilityHidden(true)
                                    .foregroundStyle(.accent)
                                VStack(alignment: .leading) {
                                    Text(action.displayName)
                                        .font(.headline)
                                    Text(action.actionDescription)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if manager.settings.selected == action {
                                    Label("Selected", systemImage: "checkmark")
                                        .foregroundStyle(.accent)
                                        .bold()
                                        .labelStyle(.iconOnly)
                                        .accessibilityAddTraits([.isSelected])
                                }
                            }
                        }
                    }
                }
            } // List
            .navigationTitle("Wake-up Action")
            .toolbarTitleDisplayMode(.inline)
        } // NavigationStack
    }
}

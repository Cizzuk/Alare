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
                        NavigationLink(destination: ActionSettingsView(action: action)) {
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
                
                Section {
                    Toggle(isOn: $manager.settings.relaxationMode) {
                        Label("Relaxation Mode", systemImage: "heart")
                            .foregroundStyle(.primary)
                    }
                } footer: {
                    Text("While Relaxation Mode is on, you can skip the Wake-up Action.")
                }
            } // List
            .navigationTitle("Wake-up Action")
            .toolbarTitleDisplayMode(.inline)
        } // NavigationStack
    }
    
    // MARK: - Action Settings View
    
    struct ActionSettingsView: View {
        var action: WakeupAction
        
        @StateObject private var manager = WakeupActionManager.shared
        @State private var isSelected: Bool = false
        
        var body: some View {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 5) {
                        Image(systemName: action.systemImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 50, maxHeight: 50)
                            .accessibilityHidden(true)
                            .padding(5)
                            .padding(.bottom, 10)
                            .foregroundStyle(.accent)
                        Text(action.displayName)
                            .font(.title2)
                            .bold()
                            .accessibilityAddTraits(.isHeader)
                        Text(action.actionDescription)
                            .foregroundColor(.secondary)
                    }
                    
                    Toggle("Use This Action", isOn: $isSelected)
                        .disabled(action == .default && isSelected)
                        .disabled(!action.isAvailable && !isSelected)
                        .onAppear {
                            isSelected = manager.settings.selected == action
                        }
                        .onChange(of: isSelected) {
                            if isSelected {
                                manager.settings.selected = action
                            } else {
                                manager.settings.selected = .default
                            }
                        }
                }
                
                Button(action: {}) {
                    Label("Try This Action", systemImage: "play.circle")
                }
                
                // Action-specific settings can be added here
            }
            .navigationTitle(action.displayName)
            .toolbarTitleDisplayMode(.inline)
        }
    }
}

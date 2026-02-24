//
//  WakeupActionSettingsView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/23.
//

import SwiftUI

struct WakeupActionSettingsView: View {
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
            } // List
            .navigationTitle("Wake-up Action")
            .toolbarTitleDisplayMode(.inline)
        } // NavigationStack
    }
}

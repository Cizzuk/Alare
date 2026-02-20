//
//  MainView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/18.
//

import SwiftUI

struct MainView: View {
    @StateObject private var alarm = AlarmSupport.shared
    @State private var showAlarmSettings = false

    var body: some View {
        NavigationStack {
            List {}
                .navigationTitle("Alare")
                .sheet(isPresented: $showAlarmSettings) {
                    AlarmSettingsView()
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: { showAlarmSettings = true }) {
                            Label("Edit", systemImage: "pencil")
                        }
                    }
                }
        }
    }
}

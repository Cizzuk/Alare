//
//  ScanCodeWakeupActionView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/24.
//

import SwiftUI

// MARK: - Settings

struct ScanCodeWakeupActionSettingsView: View {
    @ObservedObject private var manager = WakeupActionManager.shared

    var body: some View {
        Section {
            HStack {
                Text("Code")
                Spacer()
                if let code = manager.settings.scanCode_code {
                    Text(code)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Not Set")
                        .foregroundStyle(.secondary)
                }
            }
            Button(action: {}) {
                Text("Scan to Set a New Code")
            }
        }
    }
}

// MARK: - Execution

struct ScanCodeWakeupActionExecutionView: View {
    @ObservedObject var vm: WakeupActionExecutionViewModel
    
    var body: some View {
        EmptyView()
    }
}

//
//  ScanCodeWakeupActionView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/24.
//

import SwiftUI

struct ScanCodeWakeupActionSettingsView: View {
    @ObservedObject var manager: WakeupActionManager

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
        }
    }
}

struct ScanCodeWakeupActionExecutionView: View {
    @ObservedObject var vm: WakeupActionExecutionViewModel
    
    var body: some View {
        EmptyView()
    }
}

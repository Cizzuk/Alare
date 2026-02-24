//
//  WakeupActionExecutionView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/24.
//

import SwiftUI

struct WakeupActionExecutionView: View {
    let action: WakeupAction
    let onComplete: () -> Void
    let onCancel: () -> Void

    @StateObject private var vm: WakeupActionExecutionViewModel

    init(action: WakeupAction,
         onComplete: @escaping () -> Void,
         onCancel: @escaping () -> Void)
    {
        self.action = action
        self.onComplete = onComplete
        self.onCancel = onCancel
        _vm = StateObject(
            wrappedValue: WakeupActionExecutionViewModel(action: action, onComplete: onComplete)
        )
    }

    var body: some View {
        NavigationStack {
            action.executionView(vm: vm)
                .navigationTitle(action.displayName)
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: onCancel) {
                            Label("Cancel", systemImage: "xmark")
                        }
                    }
                }
        }
    }
}

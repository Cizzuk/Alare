//
//  WakeupActionExecutionViewModel.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/24.
//

import Combine

final class WakeupActionExecutionViewModel: ObservableObject {
    let action: WakeupAction
    private let onComplete: () -> Void

    @Published private(set) var isCompleted = false

    init(action: WakeupAction, onComplete: @escaping () -> Void) {
        self.action = action
        self.onComplete = onComplete
    }

    func complete() {
        guard !isCompleted else { return }
        isCompleted = true
        onComplete()
    }
}

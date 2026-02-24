//
//  DrumRollWakeupActionView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/24.
//

import SwiftUI

struct DrumRollWakeupActionSettingsView: View {
    @ObservedObject var manager: WakeupActionManager
    
    @State private var showPicker = false
    private let tapsIntList = Array(10...500)

    var body: some View {
        Section {
            HStack {
                Text("Required Taps")
                Spacer()
                Button(action: { withAnimation { showPicker.toggle() } }) {
                    Text("\(manager.settings.drumRoll_tapsRequired) Taps")
                        .font(.default.monospacedDigit())
                }
            }
            
            if showPicker {
                Picker("Required Taps", selection: $manager.settings.drumRoll_tapsRequired) {
                    ForEach(tapsIntList, id: \.self) { tapCount in
                        Text("\(tapCount)")
                            .font(.default.monospacedDigit())
                            .tag(tapCount)
                    }
                }
                .pickerStyle(.wheel)
            }
        }
    }
}

struct DrumRollWakeupActionExecutionView: View {
    @ObservedObject var vm: WakeupActionExecutionViewModel
    
    let tapsRequired = WakeupActionManager.shared.settings.drumRoll_tapsRequired

    @State private var taps = 0
    
    func addTap() {
        if taps >= tapsRequired - 1 {
            vm.complete()
        } else {
            taps += 1
            // Random feedback
            let feedbackTypes: [UIImpactFeedbackGenerator.FeedbackStyle] = [
                .medium, .heavy, .rigid
            ]
            let randomType = feedbackTypes.randomElement() ?? .medium
            UIImpactFeedbackGenerator(style: randomType).impactOccurred()
        }
    }

    var body: some View {
        LazyVStack(spacing: 50) {
            Text("Drum Roll!")
                .font(.largeTitle)
                .bold()
            Text("\(tapsRequired - taps) remaining")
                .font(.title.monospacedDigit())
                .foregroundStyle(.secondary)
            Spacer(minLength: 100)
            Circle()
                .fill(.dropblue)
                .glassEffect()
                .frame(width: 150, height: 150)
                .onTapGesture { addTap() }
                .accessibilityAddTraits(.isButton)
        }
        .padding()
    }
}

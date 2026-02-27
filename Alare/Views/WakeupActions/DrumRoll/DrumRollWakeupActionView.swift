//
//  DrumRollWakeupActionView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/24.
//

import SwiftUI
import UIKit

// MARK: - Settings

struct DrumRollWakeupActionSettingsView: View {
    @ObservedObject private var manager = WakeupActionManager.shared
    
    @State private var showPicker = false
    private let tapsIntList = Array(stride(from: 10, through: 200, by: 10)) + Array(stride(from: 300, through: 1000, by: 100))

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

// MARK: - Execution

struct DrumRollWakeupActionExecutionView: View {
    @ObservedObject var vm: WakeupActionExecutionViewModel
    
    private let tapsRequired = WakeupActionManager.shared.settings.drumRoll_tapsRequired

    @State private var taps = 0
    
    private func remainingTaps() -> Int {
        max(tapsRequired - taps, 0)
    }

    var body: some View {
        VStack(spacing: 50) {
            Text("Drum Roll the Screen to Wake Up!")
                .font(.largeTitle)
                .bold()
                .padding()
            
            Image(systemName: "hand.tap")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(.accent)
                .accessibilityHidden(true)
            
            Text("\(remainingTaps()) remaining")
                .font(.title.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(NightGradient.ignoresSafeArea())
        .overlay {
            MultiTouchTapView { touchCount in
                addTap(count: touchCount)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityDirectTouch()
        .accessibilityLabel("Drum Roll the Screen to Wake Up!")
        .accessibilityHint("\(tapsRequired - taps) remaining")
    }
    
    private func addTap(count: Int = 1) {
        taps += count
        if taps >= tapsRequired {
            vm.complete()
        } else {
            // Random feedback
            let feedbackTypes: [UIImpactFeedbackGenerator.FeedbackStyle] = [
                .medium, .heavy, .rigid
            ]
            let randomType = feedbackTypes.randomElement() ?? .medium
            UIImpactFeedbackGenerator(style: randomType).impactOccurred()
        }
    }
    
    private struct MultiTouchTapView: UIViewRepresentable {
        let onTap: (Int) -> Void

        func makeUIView(context: Context) -> TouchView {
            let view = TouchView()
            view.onTap = onTap
            return view
        }

        func updateUIView(_ uiView: TouchView, context: Context) {
            uiView.onTap = onTap
        }
    }

    private final class TouchView: UIView {
        var onTap: ((Int) -> Void)?

        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .clear
            isMultipleTouchEnabled = true
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesBegan(touches, with: event)
            let count = max(touches.count, 1)
            onTap?(count)
        }
    }
}

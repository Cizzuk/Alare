//
//  TapButtonWakeupActionView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/24.
//

import SwiftUI

struct TapButtonWakeupActionExecutionView: View {
    @ObservedObject var vm: WakeupActionExecutionViewModel

    var body: some View {
        LazyVStack(spacing: 150) {
            Label("Good Morning", systemImage: "sun.horizon.fill")
                .font(.largeTitle)
                .bold()
            Button(action: { vm.complete() }) {
                Text("I'm Awake!")
                    .frame(maxWidth: .infinity)
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
                    .padding(30)
            }
            .tint(.dropblue)
            .buttonStyle(.glassProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(NightGradient.ignoresSafeArea())
    }
}

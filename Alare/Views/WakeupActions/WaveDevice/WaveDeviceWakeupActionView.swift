//
//  WaveDeviceWakeupActionView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/24.
//

import CoreMotion
import SwiftUI

// MARK: - Settings

struct WaveDeviceWakeupActionSettingsView: View {
    @ObservedObject private var manager = WakeupActionManager.shared
    
    @State private var showPicker = false
    private let durationList = Array(stride(from: 10, through: 40, by: 10)) + Array(stride(from: 50, through: 300, by: 50))

    var body: some View {
        Section {
            HStack {
                Text("Required Points")
                Spacer()
                Button(action: { withAnimation { showPicker.toggle() } }) {
                    Text("\(manager.settings.waveDevice_pointsRequired) Points")
                        .font(.default.monospacedDigit())
                }
            }
            
            if showPicker {
                Picker("Required Points", selection: $manager.settings.waveDevice_pointsRequired) {
                    ForEach(durationList, id: \.self) { duration in
                        Text("\(duration)")
                            .font(.default.monospacedDigit())
                            .tag(duration)
                    }
                }
                .pickerStyle(.wheel)
            }
        } footer: {
            Text("It's easier to earn points by making large, slow movements with your device rather than quick, small shakes.")
        }
        
        Section {} footer: {
            Text("When performing this action, please hold your device securely and be aware of your surroundings.")
        }
    }
}

// MARK: - Execution

struct WaveDeviceWakeupActionExecutionView: View {
    @ObservedObject var vm: WakeupActionExecutionViewModel
    
    @State private var motionManager = CMMotionManager()
    @State private var progress: Int = 0
    
    private let pointsRequired = WakeupActionManager.shared.settings.waveDevice_pointsRequired
    
    private let updateInterval: TimeInterval = 0.1
    private let gyroCancelRate: Double = 15.0
    private let threshold: Double = 0.5
    
    private var remainingPoints: Int {
        max(pointsRequired - progress, 0)
    }

    var body: some View {
        VStack(spacing: 50) {
            Text("Wave the Device to Wake Up!")
                .font(.largeTitle)
                .bold()
                .padding()
            
            Gauge(value: Double(progress), in: 0...Double(pointsRequired)) {
                Image(systemName: "flag")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.dropblue)
                    .padding(3)
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(.dropblue)
            .scaleEffect(3)
            .padding(50)
            .accessibilityHidden(true)
            
            Text("\(remainingPoints) Points Left")
                .font(.title.monospacedDigit())
                .foregroundStyle(.secondary)
            
            Text("When performing this action, please hold your device securely and be aware of your surroundings.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .animation(.easeInOut, value: progress)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(NightGradient.ignoresSafeArea())
        .onAppear() { startMotionUpdates() }
        .onDisappear() { stopMotionUpdates() }
    }
    
    // MARK: Motion
    
    private func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = updateInterval
        motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
            guard let motion = motion else { return }
            
            // Acceleration
            let a = motion.userAcceleration
            let accel = sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
            
            // Gyroscope
            let g = motion.rotationRate
            let gyro = sqrt(g.x * g.x + g.y * g.y + g.z * g.z)
            
            // Cancel acceleration when gyro is strong (shake device)
            let scale = max(1.0 - gyro / gyroCancelRate, 0)
            let effective = accel * scale
            
            print("Accel: \(accel), \nGyro: \(gyro), \nEffective: \(effective)")
            
            if effective > threshold {
                progress += 1
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                
                if progress >= pointsRequired {
                    vm.complete()
                    stopMotionUpdates()
                }
            }
        }
    }
    
    private func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}

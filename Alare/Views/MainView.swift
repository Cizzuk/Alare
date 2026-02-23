//
//  MainView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/18.
//

import AlarmKit
import SwiftUI
import UniformTypeIdentifiers

struct MainView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var register = AlarmRegister.shared
    @StateObject private var vm = MainViewModel()
    
    @State private var showCustomSoundImporter = false

    var body: some View {
        NavigationStack {
            List {
                if register.registereds.nextSnooze != nil {
                    Section {
                        Button(action: { vm.killAlarm() }) {
                            Label("Stop with Wake up Action", systemImage: "stop.circle")
                        }
                    } header: {
                        Label("Alarm is Snoozing", systemImage: "zzz")
                            .foregroundStyle(.primary)
                    }
                }
                
                Section {} header: {
                    HStack {
                        Text(vm.titleText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.largeTitle)
                            .bold()
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityLabel("Alare")
                        Spacer()
                        Toggle("Turn on Alarm", isOn: $vm.draft.isEnabled)
                            .disabled(AlarmManager.shared.authorizationState == .denied)
                            .labelsHidden()
                    }
                    .foregroundStyle(.primary)
                } footer: {
                    VStack {
                        DatePicker("Time", selection: $vm.timeSelection, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                        if AlarmManager.shared.authorizationState == .denied {
                            Text("Alarm permission is not granted. Please enable it in Settings to use the Alare.")
                        }
                    }
                    .padding(.bottom, 30)
                }
                
                Section("Repeat") {
                    WeekdaysView(repeats: $vm.draft.repeats)
                }
                
                Section("Options") {
                    Stepper(value: $vm.draft.snoozeInterval, in: 1...15) {
                        HStack {
                            Text("Snooze Duration")
                            Spacer()
                            Text("\(vm.draft.snoozeInterval)m")
                                .font(.default.monospacedDigit())
                        }
                    }
                    .onChange(of: vm.draft.snoozeInterval) {
                        UISelectionFeedbackGenerator().selectionChanged()
                    }
                    
                    Picker("Sound", selection: $vm.draft.sound) {
                        ForEach(AlarmSound.allCases, id: \.self) { sound in
                            Text(sound.displayName).tag(sound)
                        }
                    }
                    if vm.draft.sound == .custom {
                        Button(action: { showCustomSoundImporter = true }) {
                            Text("Import Custom Sound")
                        }
                    }
                }
                
                Section {
                    NavigationLink(destination: AboutView()) {
                        Label("About", systemImage: "info.circle")
                            .foregroundColor(.primary)
                    }
                    if UIApplication.shared.supportsAlternateIcons {
                        NavigationLink(destination: ChangeIconView()) {
                            Label("Change App Icon", systemImage: "app.dashed")
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                #if !targetEnvironment(simulator)
                Section {
                    // 時刻と繰り返しの設定をして、アラームをオンにします。
                    // アラームが鳴ると、画面に「スヌーズ」と「停止」ボタンが表示されます。
                    // しかし、どちらを選択しても、強制的にスヌーズがかかります。
                    // 停止を選択すると、Alareアプリが開きます。アプリ内で停止ボタンを押さない限り、強制スヌーズが続きます。
                    // 今後のアップデートで停止するために必要なアクションを増やす予定です。
                    Text("Set the time and repeat settings, and then turn on the alarm.")
                    Text("When the alarm rings, Snooze and Stop buttons will appear on the screen.")
                    Text("However, regardless of which you select, it will be forced into snooze mode.")
                    Text("If you select the stop, the Alare app will open. Forced snooze will continue unless you press the stop button in the app.")
                    Text("I plan to increase the required actions to stop in future updates.")
                } header: { Label("What is this", systemImage: "questionmark.circle") }
                Section {
                    Text("Its operation may be unstable, and settings may not be carried over to future versions.")
                    Text("I would appreciate it if you could send us feedback if you encounter any issues.")
                    Link(destination:URL(string: "https://github.com/Cizzuk/Alare")!, label: {
                        Label("Source", systemImage: "ladybug")
                    })
                    Link(destination:URL(string: "https://cizzuk.net/contact/")!, label: {
                        Label("Contact", systemImage: "envelope")
                    })
                } header: { Label("This app is currentry in Beta", systemImage: "exclamationmark.circle") }
                #endif
                
            } // List
            .toolbarBackground(.visible, for: .navigationBar)
            .animation(.default, value: register.registereds.nextSnooze != nil)
            .animation(.default, value: vm.draft.sound)
            .scrollContentBackground(.hidden)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.dropblue.opacity(0.2), Color(.systemGroupedBackground)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        } // NavigationStack
        .fileImporter(
            isPresented: $showCustomSoundImporter,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: false
        ) { result in
            vm.importCustomSound(result)
        }
        // MARK: - Events
        .onAppear { vm.onAppear() }
        .onChange(of: scenePhase) { vm.onChange(scenePhase: scenePhase) }
    }
}

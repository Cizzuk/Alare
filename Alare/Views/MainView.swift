//
//  MainView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/18.
//

import SwiftUI

struct MainView: View {
    @StateObject private var alarm = AlarmManager.shared
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        NavigationStack {
            List {
                VStack(alignment: .leading) {
                    Text(String(format: "%02d:%02d", alarm.alarm.hour, alarm.alarm.minute))
                        .font(.largeTitle)
                }
            }
        }
    }
}

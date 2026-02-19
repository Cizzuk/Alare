//
//  MainView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/18.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var alarms: [AlarmData]

    var body: some View {
        NavigationStack {
            List {
                ForEach(alarms) { item in
                    VStack(alignment: .leading) {
                        Text(String(format: "%02d:%02d", item.hour, item.minute))
                            .font(.title)
                    }
                }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(alarms[index])
        }
    }
}

#Preview {
    MainView()
        .modelContainer(for: AlarmData.self, inMemory: true)
}

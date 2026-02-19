//
//  AlarmsView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/18.
//

import SwiftUI
import SwiftData

struct AlarmsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var alarms: [AlarmData]

    var body: some View {
        NavigationStack {
            List {
                ForEach(alarms) { item in
                    VStack(alignment: .leading) {
                        Text(String(format: "%02d:%02d", item.hour, item.minute))
                            .font(.title)
                        Text(item.name)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: addItem) {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = AlarmData()
            newItem.name = "Alarm"
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(alarms[index])
            }
        }
    }
}

#Preview {
    AlarmsView()
        .modelContainer(for: AlarmData.self, inMemory: true)
}

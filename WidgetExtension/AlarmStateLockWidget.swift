//
//  AlarmStateLockWidget.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/26.
//

import SwiftUI
import WidgetKit

struct AlarmStateLockWidget: Widget {
    static let kind = "net.cizzuk.alare.WidgetExtension.AlarmStateLockWidget"
    static let title: LocalizedStringResource = "Alare"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: Provider()) { entry in
            AlarmStateLockWidgetView(entry: entry)
        }
        .configurationDisplayName(Self.title)
        .description("Display Alare's alarm status.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }

    struct Entry: TimelineEntry {
        let date: Date
    }
    
    struct Provider: TimelineProvider {
        func placeholder(in context: Context) -> Entry {
            Entry(date: Date())
        }

        func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
            completion(Entry(date: Date()))
        }

        func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
            let entry = Entry(date: Date())
            completion(Timeline(entries: [entry], policy: .never))
        }
    }
    
    struct AlarmStateLockWidgetView: View {
        let entry: Entry
        private let settings = AlarmSettings.load()
        private let registeredAlarms = RegisteredAlarms.load()

        var body: some View {
            VStack(alignment: .center, spacing: 8) {
                if registeredAlarms.nextSnooze != nil {
                    Label("Start Wake-up Action", image: "bolt.alare")
                        .font(.system(size: 50))
                        .labelStyle(.iconOnly)
                    Label("Snoozing", systemImage: "zzz")
                        .font(.headline)
                } else if settings.isEnabled {
                    Label("Alare", image: "alare")
                        .font(.system(size: 50))
                        .labelStyle(.iconOnly)
                    Text(String(format: "%02d:%02d", settings.hour, settings.minute))
                        .font(.system(.title, design: .rounded))
                        .monospacedDigit()
                        .bold()
                } else {
                    Label("Alare", image: "alare")
                        .font(.system(size: 50))
                        .labelStyle(.iconOnly)
                    Text("Alarm is Off")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
            

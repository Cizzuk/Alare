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
            Group {
                if registeredAlarms.nextSnooze != nil {
                    Image("bolt.alare")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .accessibilityLabel("Start Wake-up Action")
                } else if settings.isEnabled {
                    Image("alare")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .accessibilityLabel("Alarm is On")
                } else {
                    Image("alare")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .accessibilityLabel("Alarm is Off")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .containerBackground(.clear, for: .widget)
        }
    }
}
            

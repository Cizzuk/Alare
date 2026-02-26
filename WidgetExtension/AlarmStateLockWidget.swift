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
        @Environment(\.widgetFamily) var widgetFamily
        
        let entry: Entry
        private let settings = AlarmSettings.load()
        private let registeredAlarms = RegisteredAlarms.load()

        var body: some View {
            let time: String = String(format: "%2d:%02d", settings.hour, settings.minute)
            let image: some View = {
                let name = registeredAlarms.nextSnooze != nil ? "bolt.alare" : "alare"
                return Image(name)
                    .resizable()
                    .scaledToFit()
                    .accessibilityHidden(true)
            }()
            
            ZStack(alignment: .center) {
                switch widgetFamily {
                case .accessoryRectangular:
                    HStack {
                        image
                            .frame(width: 40, height: 40)
                        
                        if registeredAlarms.nextSnooze != nil {
                            Text("Snoozing")
                                .font(.headline)
                                .bold()
                        } else if settings.isEnabled {
                            Text(time)
                                .font(.system(size: 30, design: .rounded))
                        } else {
                            Text("Alarm Off")
                                .font(.subheadline)
                                .bold()
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                case .accessoryCircular:
                    VStack {
                        if registeredAlarms.nextSnooze != nil {
                            image
                                .frame(width: .infinity, height: .infinity)
                                .accessibilityLabel("Start Wake-up Action")
                                .accessibilityHidden(false)
                        } else {
                            image
                                .frame(width: .infinity, height: .infinity)
                            if settings.isEnabled {
                                Text(time)
                                    .font(.system(.caption, design: .rounded))
                                    .bold()
                            } else {
                                Text("Off")
                                    .font(.caption)
                                    .bold()
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                case .accessoryInline:
                    Label {
                        if registeredAlarms.nextSnooze != nil {
                            Text("Snoozing")
                        } else if settings.isEnabled {
                            Text(time)
                        } else {
                            Text("Alarm Off")
                        }
                    } icon: {
                        image
                    }
                default:
                    EmptyView()
                }
            }
            .containerBackground(.clear, for: .widget)
        }
    }
}
            

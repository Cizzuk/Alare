//
//  HomeWidget.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/26.
//

import SwiftUI
import WidgetKit

struct AlarmStateWidget: Widget {
    static let kind = "net.cizzuk.alare.WidgetExtension.AlarmStateWidget"
    static let title: LocalizedStringResource = "Alare"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: Provider()) { entry in
            AlarmStateWidgetView(entry: entry)
                .environment(\.colorScheme, .dark)
        }
        .configurationDisplayName(Self.title)
        .description("Display Alare's alarm status.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
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
    
    struct AlarmStateWidgetView: View {
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
                    WeekdaysView(repeats: settings.repeats)
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
            .containerBackground(for: .widget) {
                Color.black.overlay(NightGradient)
            }
        }
    }
    
    struct WeekdaysView: View {
        var repeats: Set<Locale.Weekday>
        
        private let weekdays: Array<Locale.Weekday> = {
            let all: Array<Locale.Weekday> = [
                .sunday,
                .monday,
                .tuesday,
                .wednesday,
                .thursday,
                .friday,
                .saturday,
            ]
            return rotateArrayWithFirstWeekday(all)
        }()
        
        private let symbol: [String] = rotateArrayWithFirstWeekday(Calendar.current.weekdaySymbols)
        
        private let shortSymbol: [String] = rotateArrayWithFirstWeekday(Calendar.current.veryShortWeekdaySymbols)
        
        private static func rotateArrayWithFirstWeekday<T>(_ array: [T]) -> [T] {
            let rotateCount = Calendar.current.firstWeekday - 1
            return Array(array[rotateCount...] + array[..<rotateCount])
        }
        
        private func isEveryday() -> Bool {
            return repeats.count == 7
        }
        
        private func isWeekdayOnly() -> Bool {
            return repeats.count == 5 && !repeats.contains(.sunday) && !repeats.contains(.saturday)
        }
        
        var body: some View {
            ZStack {
                if repeats.isEmpty {
                    Text("No Repeat")
                } else if isEveryday() {
                    Label("Everyday", systemImage: "repeat")
                } else if isWeekdayOnly() {
                    Label("Weekdays", systemImage: "repeat")
                } else {
                    HStack(spacing: 5) {
                        Label("Repeat", systemImage: "repeat")
                            .labelStyle(.iconOnly)
                        ForEach(Array(weekdays.enumerated()), id: \.element) { index, weekday in
                            if repeats.contains(weekday) {
                                if repeats.count > 1 {
                                    Text(shortSymbol[index])
                                        .accessibilityLabel(symbol[index])
                                } else {
                                    Text(symbol[index])
                                }
                            }
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 400, alignment: .center)
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
            

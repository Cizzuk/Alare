//
//  SnoozeActivityWidget.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/26.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct SnoozeActivityWidget: Widget {
    static let kind = "net.cizzuk.alare.WidgetExtension.SnoozeActivityWidget"
    
    private var largeImage: some View {
        Image("bolt.alare")
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
            .accessibilityLabel("Alare")
            .foregroundStyle(.dropblue)
    }
    
    private var smallImage: some View {
        Image("bolt.alare")
            .resizable()
            .scaledToFit()
            .accessibilityLabel("Alare")
            .foregroundStyle(.dropblue)
    }
    
    private var descriptionText: some View {
        VStack(alignment: .leading) {
            Text("Snoozing")
                .font(.headline)
                .bold()
                .foregroundStyle(.dropblue)
            Text("Start Wake-up Action")
                .font(.subheadline)
                .foregroundStyle(.dropblue.opacity(0.8))
        }
    }
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SnoozeActivityAttributes.self) { context in
            HStack(spacing: 10) {
                largeImage
                descriptionText
            }
            .padding()
            .activitySystemActionForegroundColor(.dropblue)
            .widgetURL(URL(string: "net.cizzuk.alare://wakeupaction"))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    largeImage
                }
                DynamicIslandExpandedRegion(.center) {
                    descriptionText
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 5)
                }
            } compactLeading: {
                smallImage
            } compactTrailing: {
            } minimal: {
                smallImage
            }
            .keylineTint(.dropblue)
            .widgetURL(URL(string: "net.cizzuk.alare://wakeupaction"))
        }
    }
}

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
    
    struct iconImage: View {
        var size: CGFloat? = nil

        var body: some View {
            Image("bolt.alare")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .accessibilityLabel("Alare")
                .foregroundStyle(.dropblue)
        }
    }
    
    struct descriptionText: View {
        var showSubtitle: Bool = true
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("Snoozing")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.dropblue)
                if showSubtitle {
                    Text("Start Wake-up Action")
                        .font(.subheadline)
                        .foregroundStyle(.dropblue.opacity(0.8))
                }
            }
        }
    }
    
    struct MainActivityView: View {
        @Environment(\.activityFamily) var activityFamily
        
        var body: some View {
            switch activityFamily {
            case .small:
                HStack(spacing: 10) {
                    iconImage(size: 30)
                    descriptionText(showSubtitle: false)
                }
            case .medium:
                HStack(spacing: 10) {
                    iconImage(size: 50)
                    descriptionText()
                }
                .padding()
            @unknown default:
                EmptyView()
            }
        }
    }
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SnoozeActivityAttributes.self) { context in
            MainActivityView()
                .activitySystemActionForegroundColor(.dropblue)
                .widgetURL(URL(string: "net.cizzuk.alare://wakeupaction"))
            
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    iconImage(size: 60)
                }
                DynamicIslandExpandedRegion(.center) {
                    descriptionText()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 5)
                }
            } compactLeading: {
                iconImage()
            } compactTrailing: {
            } minimal: {
                iconImage()
            }
            .keylineTint(.dropblue)
            .widgetURL(URL(string: "net.cizzuk.alare://wakeupaction"))
        }
        .supplementalActivityFamilies([.small])
    }
}

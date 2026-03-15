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
    
    struct IconImage: View {
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
    
    struct DescriptionText: View {
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
                    IconImage(size: 30)
                    DescriptionText(showSubtitle: false)
                }
            case .medium:
                HStack(spacing: 10) {
                    IconImage(size: 50)
                    DescriptionText()
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
                    IconImage(size: 60)
                        .frame(maxHeight: .infinity)
                }
                DynamicIslandExpandedRegion(.center) {
                    DescriptionText()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 5)
                }
            } compactLeading: {
                IconImage()
            } compactTrailing: {
            } minimal: {
                IconImage()
            }
            .keylineTint(.dropblue)
            .widgetURL(URL(string: "net.cizzuk.alare://wakeupaction"))
        }
        .supplementalActivityFamilies([.small])
    }
}

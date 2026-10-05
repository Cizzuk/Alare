//
//  SnoozeActivityWidget.swift
//  Alare Widget Extension
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
    
    struct SnoozeCount: View {
        var count: Int
        
        var body: some View {
            Text("\(count)")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.dropblue)
                .accessibilityLabel("\(count) Snoozed")
        }
    }
    
    struct DescriptionText: View {
        var count: Int
        var showSubtitle: Bool = true
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("\(count) Snoozed")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.primary)
                if showSubtitle {
                    Text("Start Wake-up Action")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    struct MainActivityView: View {
        @Environment(\.activityFamily) var activityFamily
        var context: ActivityViewContext<SnoozeActivityAttributes>
        
        var body: some View {
            switch activityFamily {
            case .small:
                HStack(spacing: 10) {
                    IconImage(size: 30)
                        .accessibilityHidden(true)
                    DescriptionText(count: context.state.snoozeCount, showSubtitle: false)
                }
            case .medium:
                HStack(spacing: 15) {
                    IconImage(size: 50)
                        .accessibilityHidden(true)
                    DescriptionText(count: context.state.snoozeCount)
                }
                .padding()
            @unknown default:
                EmptyView()
            }
        }
    }
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SnoozeActivityAttributes.self) { context in
            MainActivityView(context: context)
                .activityBackgroundTint(.clear)
                .widgetURL(URL(string: "net.cizzuk.alare://wakeupaction"))
            
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    IconImage(size: 60)
                        .accessibilityHidden(true)
                        .frame(maxHeight: .infinity)
                }
                DynamicIslandExpandedRegion(.center) {
                    DescriptionText(count: context.state.snoozeCount)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 5)
                }
            } compactLeading: {
                IconImage(size: 25)
            } compactTrailing: {
                SnoozeCount(count: context.state.snoozeCount)
                    .padding(.horizontal, 3)
            } minimal: {
                IconImage(size: 25)
            }
            .keylineTint(.dropblue)
            .widgetURL(URL(string: "net.cizzuk.alare://wakeupaction"))
        }
        .supplementalActivityFamilies([.small])
    }
}

//
//  WeekdaysView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/22.
//

import SwiftUI

struct WeekdaysView: View {
    @Binding var repeats: Set<Locale.Weekday>
    
    private let weekdays: Array<Locale.Weekday> = WeekdaysSupport.weekdays
    private let symbol: [String] = WeekdaysSupport.symbol
    private let veryShortSymbol: [String] = WeekdaysSupport.veryShortSymbol
    
    private func toggle(_ weekday: Locale.Weekday) {
        if repeats.contains(weekday) {
            repeats.remove(weekday)
        } else {
            repeats.insert(weekday)
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    var body: some View {
        ZStack {
            HStack(spacing: 15) {
                ForEach(Array(weekdays.enumerated()), id: \.element) { index, weekday in
                    let isOn = repeats.contains(weekday)
                    
                    Button(action: { toggle(weekday) }) {
                        ZStack {
                            Circle()
                                .fill(isOn ? .dropblue : .clear)
                                .stroke(isOn ? .dropblue : .secondary, lineWidth: 1.5)
                            
                            Text(veryShortSymbol[index])
                                .accessibilityLabel(symbol[index])
                                .fontWeight(.semibold)
                                .foregroundStyle(isOn ? .white : .secondary)
                        }
                        
                    }
                    .accessibilityAddTraits(isOn ? [.isToggle, .isSelected] : [.isToggle])
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: 400, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

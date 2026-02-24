//
//  WeekdaysView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/22.
//

import SwiftUI

struct WeekdaysView: View {
    @Binding var repeats: Set<Locale.Weekday>
    
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
                            
                            Text(shortSymbol[index])
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

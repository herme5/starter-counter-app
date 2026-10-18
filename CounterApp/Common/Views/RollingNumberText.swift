//
//  RollingNumberText.swift
//  CounterApp
//

import SwiftUI

/// Displays an integer that rolls through intermediate values when it changes.
///
/// Small changes animate directly with a numeric content transition. Larger ones
/// step through intermediate values over `duration`, so the number visibly counts.
struct RollingNumberText: View {
    let value: Int
    var duration: TimeInterval = 0.4

    @State private var displayedValue = 0
    @State private var countsDown = false
    @State private var rollingTask: Task<Void, Never>?

    var body: some View {
        Text(displayedValue, format: .number)
            .contentTransition(.numericText(countsDown: countsDown))
            .onChange(of: value, initial: true) { oldValue, newValue in
                countsDown = oldValue > newValue
                roll(to: newValue)
            }
            .onDisappear { rollingTask?.cancel() }
    }

    private func roll(to target: Int) {
        rollingTask?.cancel()
        rollingTask = nil

        let distance = abs(target - displayedValue)
        guard distance > 9 else {
            withAnimation { displayedValue = target }
            return
        }

        let step = distance > 99 ? 9 : 1
        let stepCount = (Double(distance) / Double(step)).rounded(.up)
        let interval = max(0.006, duration / stepCount)

        rollingTask = Task {
            while !Task.isCancelled, displayedValue != target {
                let delta = min(step, abs(target - displayedValue))
                withAnimation { displayedValue += target > displayedValue ? delta : -delta }
                try? await Task.sleep(for: .seconds(interval))
            }
        }
    }
}

#Preview {
    @Previewable @State var value = 0

    VStack(spacing: 20) {
        RollingNumberText(value: value)
            .font(.system(size: 42, weight: .bold))
        Button("Add 500") { value += 500 }
        Button("Add 1") { value += 1 }
    }
}

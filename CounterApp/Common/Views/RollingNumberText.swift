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
    let duration: TimeInterval

    @State private var displayedValue: Int
    @State private var countsDown = false
    @State private var rollingTask: Task<Void, Never>?

    init(value: Int, duration: TimeInterval = 0.4) {
        self.value = value
        self.duration = duration
        _displayedValue = State(initialValue: value)
    }

    var body: some View {
        Text(displayedValue, format: .number)
            .contentTransition(.numericText(countsDown: countsDown))
            .onChange(of: value) { _, newValue in roll(to: newValue) }
            .onDisappear { rollingTask?.cancel() }
    }

    private func roll(to target: Int) {
        rollingTask?.cancel()
        rollingTask = nil
        countsDown = target < displayedValue

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
        HStack(spacing: 20) {
            Button("+1") { value += 1 }
            Button("+5") { value += 5 }
            Button("+10") { value += 10 }
            Button("+500") { value += 500 }
        }
        HStack(spacing: 20) {
            Button("-1") { value -= 1 }
            Button("-5") { value -= 5 }
            Button("-10") { value -= 10 }
            Button("-500") { value -= 500 }
        }
    }
}

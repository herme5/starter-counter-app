//
//  CounterView.swift
//  CounterApp
//

import Combine
import SwiftUI

struct CounterView: View {
    private let counterAnimationDurationSec = 0.4
    private let spacing = CGFloat(12)
    private let buttonSize = CGSize(width: 80, height: 80)
    private var counterSize: CGSize {
        CGSize(
            width: buttonSize.width * 2 + spacing,
            height: buttonSize.width * 2 + spacing
        )
    }

    @StateObject var viewModel: CounterViewModel
    @State private var currentCounter: Int = 0
    @State private var decreasing = false
    @State private var showErrorAnimation = 0
    @State private var counterAnimationTask: Task<Void, Never>? = nil

    var body: some View {
        GeometryReader { geo in
            let isPortait = geo.size.height >= geo.size.width

            ZStack {
                Color.primaryBackground

                if isPortait {
                    VStack(spacing: spacing) {
                        counterBlock
                        controlBlock
                    }
                } else {
                    HStack(spacing: spacing) {
                        counterBlock
                        controlBlock
                    }
                }
            }
        }
    }

    private var counterBlock: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.primaryForeground)
                .frame(
                    width: counterSize.width,
                    height: counterSize.height
                )
            Text(currentCounter, format: .number)
                .contentTransition(.numericText(countsDown: decreasing))
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(.primaryBackground)
                .frame(width: counterSize.width)
                .shake(trigger: showErrorAnimation, duration: 0.6)
                .onChange(of: viewModel.counter, initial: true) { oldValue, newValue in
                    decreasing = oldValue > newValue
                    counterRollingAnimation(to: newValue)
                }
                .onSignal(of: viewModel.overflowError) {
                    triggerErrorAnimation()
                }
        }
    }

    private var controlBlock: some View {
        VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                controlButton(
                    action: viewModel.increment,
                    imageSystemName: "plus.square.fill"
                )
                controlButton(
                    action: viewModel.decrement,
                    imageSystemName: "minus.square.fill"
                )
            }
            fullWidthButton(
                action: viewModel.reset,
                label: "⌫ Reset"
            )
        }
    }

    private func controlButton(
        action: @escaping () -> Void,
        imageSystemName: String
    ) -> some View {
        Button(action: action) {
            Image(systemName: imageSystemName)
                .resizable()
        }
        .frame(
            width: buttonSize.width,
            height: buttonSize.height
        )
        .foregroundStyle(.primaryForeground)
    }

    private func fullWidthButton(
        action: @escaping () -> Void,
        label: String
    ) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primaryBackground)
                .frame(
                    width: counterSize.width,
                    height: buttonSize.height
                )
                .background(
                    .primaryForeground,
                    in: RoundedRectangle(cornerRadius: 12)
                )
        }
        .foregroundStyle(.primaryForeground)
    }

    private func triggerErrorAnimation() {
        withAnimation { showErrorAnimation &+= 1 }
    }

    private func counterRollingAnimation(to endValue: Int) {
        guard currentCounter != endValue else { return }
        let distance = abs(currentCounter - endValue)

        guard counterAnimationTask == nil else {
            counterAnimationTask?.cancel()
            Task {
                await Task.yield()
                counterRollingAnimation(to: endValue)
            }
            return
        }

        guard distance > 9 else {
            withAnimation { currentCounter = endValue }
            return
        }

        let step: Int = distance > 99 ? 9 : 1
        let stepCount = Double(distance / step).rounded(.up)
        let intervalSecs = max(0.006, counterAnimationDurationSec / stepCount)

        counterAnimationTask = Task {
            defer { counterAnimationTask = nil }

            do {
                while currentCounter > endValue {
                    let delta = min(step, currentCounter - endValue)
                    withAnimation { currentCounter -= delta }

                    try Task.checkCancellation()
                    try await Task.sleep(for: .seconds(intervalSecs))
                }

                while currentCounter < endValue {
                    let delta = min(step, endValue - currentCounter)
                    withAnimation { currentCounter += delta }

                    try Task.checkCancellation()
                    try await Task.sleep(for: .seconds(intervalSecs))
                }
            } catch {
                return
            }
        }
    }
}

#Preview(
    traits: .fixedLayout(width: 400, height: 400)
) {
    let settings = Settings(
        counterMin: 0,
        counterMax: 1000,
        counterStep: 100
    )
    let mockSettingsStore = MockSettingsStore(object: settings)
    let counterViewModel = CounterViewModel(settingsStore: mockSettingsStore)
    CounterView(viewModel: counterViewModel)
}

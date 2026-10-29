//
//  CounterView.swift
//  CounterApp
//

import SwiftUI

struct CounterView: View {
    private let spacing = CGFloat(12)
    private let buttonSize = CGSize(width: 80, height: 80)
    private var counterSize: CGSize {
        CGSize(
            width: buttonSize.width * 2 + spacing,
            height: buttonSize.height * 2 + spacing
        )
    }

    private let viewModel: CounterViewModel
    @State private var showErrorAnimation = 0

    init(viewModel: CounterViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geo in
            let isPortait = geo.size.height >= geo.size.width

            let layout = isPortait
            ? AnyLayout(VStackLayout(spacing: spacing))
            : AnyLayout(HStackLayout(spacing: spacing))

            layout {
                counterBlock
                controlBlock
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var counterBlock: some View {
        RollingNumberText(value: viewModel.counter)
            .font(.system(size: 42, weight: .bold))
            .shake(trigger: showErrorAnimation)
            .sensoryFeedback(.error, trigger: showErrorAnimation)
            .onReceive(viewModel.$limitReached) { _ in
                triggerErrorAnimation()
            }
            .frame(
                width: counterSize.width,
                height: counterSize.height
            )
            .knockout(.primaryForeground, in: RoundedRectangle(cornerRadius: 12))
    }

    private var controlBlock: some View {
        VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                controlButton(
                    action: viewModel.increment,
                    label: "Increase",
                    imageSystemName: "plus.square.fill"
                )
                controlButton(
                    action: viewModel.decrement,
                    label: "Decrease",
                    imageSystemName: "minus.square.fill"
                )
            }
            fullWidthButton(
                action: viewModel.reset,
                label: "Reset",
                imageSystemName: "delete.left"
            )
        }
    }

    private func controlButton(
        action: @escaping () -> Void,
        label: LocalizedStringResource,
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
        .accessibilityLabel(Text(label))
    }

    private func fullWidthButton(
        action: @escaping () -> Void,
        label: LocalizedStringResource,
        imageSystemName: String
    ) -> some View {
        Button(action: action) {
            Label { Text(label) } icon: { Image(systemName: imageSystemName) }
                .labelStyle(.titleAndIcon)
                .font(.system(size: 24, weight: .bold))
                .frame(
                    width: counterSize.width,
                    height: buttonSize.height
                )
                .knockout(.primaryForeground, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private func triggerErrorAnimation() {
        showErrorAnimation &+= 1
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
    let counterViewModel = CounterViewModel(settingsStore: .inMemory(initialValue: settings))
    CounterView(viewModel: counterViewModel)
}

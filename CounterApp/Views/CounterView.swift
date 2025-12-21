//
//  CounterView.swift
//  CounterApp
//

import Combine
import SwiftUI

struct CounterView: View {
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
    @State private var showSettings = false

    var cancellables = Set<AnyCancellable>()

    var body: some View {
        GeometryReader { geo in
            let isPortait = geo.size.height > geo.size.width

            NavigationStack {
                ZStack {
                    // Background
                    Color.primaryBackground
                        .ignoresSafeArea()

                    if isPortait {
                        // Portrait layout
                        VStack(spacing: spacing) {
                            counterBlock
                            controlBlock
                        }
                    } else {
                        // Landscape layout
                        HStack(spacing: spacing) {
                            counterBlock
                            controlBlock
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                        }
                        .foregroundStyle(.primaryForeground)
                    }
                    .sharedBackgroundVisibility(.hidden)
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView(viewModel: viewModel.makeSettingsViewModel())
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
                .onChange(of: viewModel.counter, { oldValue, newValue in
                    decreasing = oldValue > newValue
                    withAnimation {
                        currentCounter = newValue
                    }
                })
                .onReceive(viewModel.overflowError) { error in
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
        withAnimation {
            showErrorAnimation &+= 1
        }
    }
}

#Preview {
    let appFactory = AppFactory()
    CounterView(viewModel: appFactory.counterViewModel)
}

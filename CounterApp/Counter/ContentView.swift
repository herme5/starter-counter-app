//
//  CounterView.swift
//  CounterApp
//
//  Created by Workspace on 15/11/2025.
//

import SwiftUI

struct CounterView: View {
    static let spacing = CGFloat(12)
    static let buttonSize = CGSize(width: 80, height: 80)
    static let counterSize = CGSize(
        width: buttonSize.width * 2 + Self.spacing,
        height: buttonSize.width * 2 + Self.spacing
    )
    
    @State private var viewModel = CounterViewModel()
    @State private var currentCounter: UInt = 0
    @State private var showErrorAnimation = 0
    
    var body: some View {
        ZStack {
            Color.primaryBackground // Background
                .ignoresSafeArea()
            
            VStack(spacing: Self.spacing) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(.primaryForeground)
                        .frame(
                            width: Self.counterSize.width,
                            height: Self.counterSize.height
                        )
                    SlidingLabel(value: $currentCounter)
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(.primaryBackground)
                        .frame(width: Self.counterSize.width)
                        .shake(showErrorAnimation)
                        .onChange(of: viewModel.counter, { _, newValue in
                            withAnimation {
                                self.currentCounter = newValue
                            }
                        })
                }
                HStack(spacing: Self.spacing) {
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
        .onReceive(viewModel.overflowError) { error in
            triggerErrorAnimation()
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
            width: Self.buttonSize.width,
            height: Self.buttonSize.height
        )
        .foregroundStyle(.primaryForeground)
    }
    
    private func fullWidthButton(
        action: @escaping () -> Void,
        label: String
    ) -> some View {
        Button(action: action) {
            Text(label)
                .padding(12)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primaryBackground)
                .frame(
                    width: Self.counterSize.width,
                    height: Self.buttonSize.height
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
            DispatchQueue.main.async { showErrorAnimation = 0 }
        }
    }
}

#Preview {
    CounterView()
}

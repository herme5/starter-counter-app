//
//  CounterView.swift
//  CounterApp
//
//  Created by Workspace on 15/11/2025.
//

import SwiftUI

struct CounterView: View {
    
    @State private var viewModel = ViewModel()
    
    static let spacing = CGFloat(12)
    static let buttonSize = CGSize(width: 80, height: 80)
    static let counterSize = CGSize(
        width: buttonSize.width * 2 + Self.spacing,
        height: buttonSize.width * 2 + Self.spacing
    )
    
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
                    SlidingLabel(value: viewModel.counter)
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(.primaryBackground)
                }
                HStack(spacing: Self.spacing) {
                    controlButton(
                        imageSystemName: "plus.square.fill",
                        action: viewModel.increment
                    )
                    controlButton(
                        imageSystemName: "minus.square.fill",
                        action: viewModel.decrement
                    )
                }
            }
        }
    }
    
    func controlButton(imageSystemName: String, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation { action() }
        } label: {
            Image(systemName: imageSystemName)
                .resizable()
        }
        .frame(
            width: Self.buttonSize.width,
            height: Self.buttonSize.height
        )
        .foregroundStyle(.primaryForeground)
    }
}

#Preview {
    CounterView()
}

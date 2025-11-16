//
//  SlidingLabel.swift
//  CounterApp
//
//  Created by Workspace on 16/11/2025.
//

import SwiftUI

private struct OneDirectionSlidingLabel: View {
    enum SlidingDirection { case bottomInTopOut, topInBottomOut }
    
    var text: String
    var direction: SlidingDirection
    
    var body: some View {
        Text(text)
            .id(UUID()) // Makes SwiftUI see it as a new view
            .transition(
                .asymmetric(
                    insertion: insertionTransition,
                    removal: removalTransition
                )
            )
            .animation(.easeInOut(duration: 0.25), value: text)
    }
    
    var insertionTransition: AnyTransition {
        .move(edge: direction == .bottomInTopOut ? .bottom : .top)
        .combined(with: .opacity)
    }
    
    var removalTransition: AnyTransition {
        .move(edge: direction == .bottomInTopOut ? .top : .bottom)
        .combined(with: .opacity)
    }
}

struct SlidingLabel<T>: View where T: Comparable & LosslessStringConvertible {
    var value: T
    @State private var topInBottomOutLabelOpacity: Double = 1
    @State private var bottomIntopOutLabelOpacity: Double = 0
    
    var body: some View {
        ZStack {
            OneDirectionSlidingLabel(text: String(value), direction: .topInBottomOut)
                .opacity(topInBottomOutLabelOpacity)
            OneDirectionSlidingLabel(text: String(value), direction: .bottomInTopOut)
                .opacity(bottomIntopOutLabelOpacity)
        }
        .onChange(of: value) { oldValue, newValue in
            let condition = oldValue < newValue
            topInBottomOutLabelOpacity = condition ? 1 : 0
            bottomIntopOutLabelOpacity = condition ? 0 : 1
        }
    }
}

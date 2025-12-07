//
//  Shake.swift
//  CounterApp
//

import SwiftUI

fileprivate struct Shake: GeometryEffect {
    let amount: CGFloat = 12
    let shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * CGFloat(shakesPerUnit))
        return ProjectionTransform(CGAffineTransform(translationX: 0, y: translation))
    }
}

extension View {
    func shake<T: BinaryInteger>(trigger: T, duration: TimeInterval = 0.15) -> some View {
        self.modifier(
            Shake(animatableData: CGFloat(trigger))
                // .animation(.easeInOut(duration: duration))
        )
    }
}

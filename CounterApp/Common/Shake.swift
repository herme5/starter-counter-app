//
//  Shake.swift
//  CounterApp
//
//  Created by Workspace on 22/11/2025.
//

import SwiftUI

fileprivate struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * CGFloat(shakesPerUnit))
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

extension View {
    func shake(_ trigger: Int) -> some View {
        self.modifier(Shake(animatableData: CGFloat(trigger)))
    }
}


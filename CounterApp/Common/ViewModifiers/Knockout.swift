//
//  Knockout.swift
//  CounterApp
//

import SwiftUI

extension View {
    /// Fills `shape` with `style` behind the view, then cuts the view out of it.
    ///
    /// Whatever lies behind shows through the view's opaque pixels, so the result follows
    /// any background. The view's own color does not matter, only its opacity.
    func knockout(_ style: some ShapeStyle, in shape: some Shape) -> some View {
        self
            .blendMode(.destinationOut)
            .background(shape.fill(style))
            .compositingGroup()
    }
}

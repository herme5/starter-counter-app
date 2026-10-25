//
//  DebugFrame.swift
//  CounterApp
//

import SwiftUI

#if DEBUG
fileprivate enum DebugFrameColor {
    static var colorIndex = 0
    static var colors: [Color] = [.blue, .green, .orange, .red, .purple, .pink, .teal, .indigo, .brown].shuffled()

    static func nextColor() -> Color {
        colorIndex = (colorIndex + 1) % colors.count
        if colorIndex == 0 { colors.shuffle() }
        return colors[colorIndex]
    }
}

fileprivate struct HatchedRectangle: View {
    let color: Color

    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 8
            let lineWidth: CGFloat = 1

            for x in stride(from: -size.height, to: size.width, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x + size.height, y: size.height))
                context.stroke(path, with: .color(color), lineWidth: lineWidth)
            }
        }
    }
}

fileprivate struct DebugFrame: ViewModifier {
    let color: Color?

    /// Picked once per view identity, so re-renders keep the same color.
    @State private var paletteColor = DebugFrameColor.nextColor()

    func body(content: Content) -> some View {
        let color = color ?? paletteColor
        content
            .background {
                HatchedRectangle(color: color.opacity(0.2))
                    .border(color.opacity(0.4))
            }
    }
}
#endif

extension View {
#if DEBUG
    /// Hatches and outlines the view's frame, to see its layout at a glance. Debug builds only.
    ///
    /// Without a `color`, each call picks the next one from a shuffled palette.
    func debugFrame(_ color: Color? = nil) -> some View {
        self.modifier(DebugFrame(color: color))
    }
#else
    @available(*, deprecated, message: "has no effect in release builds.")
    func debugFrame(_ color: Color? = nil) -> some View {
        self
    }
#endif
}

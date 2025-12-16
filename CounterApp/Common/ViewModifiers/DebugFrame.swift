//
//  DebugFrame.swift
//  CounterApp
//

import SwiftUI

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
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .background {
                HatchedRectangle(color: color.opacity(0.2))
                    .border(color.opacity(0.4))
            }
    }
}

extension View {
    func debugFrame(_ color: Color? = nil) -> some View {
        self.modifier(DebugFrame(color: color != nil ? color! : DebugFrameColor.nextColor()))
    }
}

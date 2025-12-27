//
//  Signal.swift
//  CounterApp
//

import Combine
import SwiftUI

class Signal<T: Equatable>: ObservableObject {
    @Published fileprivate var value: T?

    func send(_ value: T) {
        self.value = value
    }

    fileprivate func reset() {
        self.value = nil
    }
}

fileprivate struct OneParameterHandlerView<T: Equatable>: ViewModifier {
    @ObservedObject var signal: Signal<T>
    var handler: (T) -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: signal.value) {
                guard let value = signal.value else { return }
                handler(value)
                signal.reset()
            }
    }
}

fileprivate struct ZeroParameterHandlerView<T: Equatable>: ViewModifier {
    @ObservedObject var signal: Signal<T>
    var handler: () -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: signal.value) {
                guard signal.value != nil else { return }
                handler()
                signal.reset()
            }
    }
}

extension View {
    func onSignal<T: Equatable>(
        of signal: Signal<T>,
        handler: @escaping (T) -> Void
    ) -> some View {
        self.modifier(OneParameterHandlerView(signal: signal, handler: handler))
    }

    func onSignal<T: Equatable>(
        of signal: Signal<T>,
        handler: @escaping () -> Void
    ) -> some View {
        self.modifier(ZeroParameterHandlerView(signal: signal, handler: handler))
    }
}

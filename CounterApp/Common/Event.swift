//
//  Event.swift
//  CounterApp
//

import Combine

/// A fire-and-forget event: each `send` reaches the current subscribers, nothing is stored.
///
/// Only the owning type can send, through the private backing storage (`_name.send(...)`).
/// Everyone else sees a read-only publisher. Inside an `@Observable` type, mark the property
/// `@ObservationIgnored`, as for any property wrapper.
@propertyWrapper
struct Event<Value> {
    private let subject = PassthroughSubject<Value, Never>()
    let wrappedValue: AnyPublisher<Value, Never>

    init() {
        wrappedValue = subject.eraseToAnyPublisher()
    }

    func send(_ value: Value) {
        subject.send(value)
    }
}

extension Event where Value == Void {
    func send() {
        send(())
    }
}

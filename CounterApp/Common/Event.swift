//
//  Event.swift
//  CounterApp
//

import Combine

/// A fire-and-forget event: each `send` reaches the current subscribers, nothing is stored.
///
/// Like `@Published`, the publisher is the projected value (`$name`). Only the owning type can
/// send, through the private backing storage (`_name.send(...)`). Inside an `@Observable` type,
/// mark the property `@ObservationIgnored`, as for any property wrapper.
@propertyWrapper
struct Event<Value> {
    /// An event has no value: subscribe to its projected publisher (`$name`) instead.
    struct NoValue {}

    private let subject = PassthroughSubject<Value, Never>()
    let projectedValue: AnyPublisher<Value, Never>
    var wrappedValue: NoValue { NoValue() }

    init() {
        projectedValue = subject.eraseToAnyPublisher()
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

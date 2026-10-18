//
//  Store.swift
//  CounterApp
//

import Combine

/// Holds a single persisted value and enforces its invariants.
///
/// `object` and `objectPublisher` only ever expose values that passed `save(_:)`,
/// so subscribers never need to validate what they receive.
protocol Store<Object>: AnyObject {
    associatedtype Object

    var object: Object { get }

    /// Emits the current value on subscription, then every saved value.
    var objectPublisher: AnyPublisher<Object, Never> { get }

    /// Throws when `object` breaks an invariant. The stored value is then left unchanged.
    func save(_ object: Object) throws
}

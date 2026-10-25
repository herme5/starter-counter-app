//
//  Store.swift
//  CounterApp
//

import Combine
import OSLog

/// Holds the current value of one kind of object, enforces its rules, and publishes every change.
///
/// `value` and `publisher` only ever expose valid values, so subscribers never need to validate
/// what they receive. Where the value is persisted is up to the `Repository`.
final class Store<Value: Validatable & Equatable> {
    private let repository: any Repository<Value>
    private let subject: CurrentValueSubject<Value, Never>

    /// Set by the first change, so a slower `load()` cannot overwrite it.
    private var hasChanged = false
    private var lastWrite: Task<Void, Never>?

    var value: Value { subject.value }

    /// Emits the current value on subscription, then every change.
    var publisher: AnyPublisher<Value, Never> { subject.eraseToAnyPublisher() }

    /// Starts with `initialValue`, which must be valid, until `load()` replaces it with the stored one.
    init(initialValue: Value, repository: any Repository<Value>) {
        assert(initialValue.isValid, "A store's initial value must be valid.")
        self.repository = repository
        self.subject = CurrentValueSubject(initialValue)
    }

    /// Fetches and publishes the stored value, unless it is missing or invalid, or the value changed in the meantime.
    func load() async {
        let stored: Value?
        do {
            stored = try await repository.load()
        } catch {
            AppLogger.store.error("Failed to load \(Self.valueName, privacy: .public): \(error.localizedDescription)")
            return
        }

        guard !hasChanged, let stored, stored.isValid, stored != subject.value else { return }
        subject.send(stored)
    }

    /// Publishes `value` right away and persists it in the background, in call order.
    ///
    /// Throws when `value` breaks a rule. The current value is then left unchanged.
    func save(_ value: Value) throws(Value.ValidationError) {
        try value.validate()
        guard value != subject.value else { return }

        hasChanged = true
        subject.send(value)
        persist(value)
    }

    /// Waits until every saved value has reached the repository.
    func flush() async {
        await lastWrite?.value
    }

    private func persist(_ value: Value) {
        let previousWrite = lastWrite
        lastWrite = Task { [repository] in
            await previousWrite?.value
            do {
                try await repository.save(value)
            } catch {
                AppLogger.store.error("Failed to persist \(Self.valueName, privacy: .public): \(error.localizedDescription)")
            }
        }
    }

    private static var valueName: String { String(describing: Value.self) }
}

//
//  Repository.swift
//  CounterApp
//

/// Reads and writes one value in one storage medium, without holding it or checking its rules.
///
/// Async so that a backend which has to wait, such as a network one, can be added
/// without changing `Store` or anything above it.
protocol Repository<Value> {
    associatedtype Value

    /// Returns `nil` when nothing has been stored yet.
    func load() async throws -> Value?

    func save(_ value: Value) async throws
}

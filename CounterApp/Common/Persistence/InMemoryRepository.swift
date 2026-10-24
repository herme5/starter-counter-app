//
//  InMemoryRepository.swift
//  CounterApp
//

/// Keeps the value in memory only, for previews, tests, and anything that should not outlive the process.
final class InMemoryRepository<Value>: Repository {
    private var stored: Value?

    init(_ initialValue: Value? = nil) {
        self.stored = initialValue
    }

    func load() async throws -> Value? {
        stored
    }

    func save(_ value: Value) async throws {
        stored = value
    }
}

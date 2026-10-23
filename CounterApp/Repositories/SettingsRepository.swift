//
//  SettingsRepository.swift
//  CounterApp
//

/// Reads and writes the settings in one storage medium, without holding them or checking their rules.
///
/// Async so that a backend which has to wait, such as a network one, can be added
/// without changing `SettingsStore` or anything above it.
protocol SettingsRepository {
    /// Returns `nil` when nothing has been stored yet.
    func load() async throws -> Settings?

    func save(_ settings: Settings) async throws
}

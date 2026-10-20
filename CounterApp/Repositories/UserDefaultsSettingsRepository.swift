//
//  UserDefaultsSettingsRepository.swift
//  CounterApp
//

import Foundation

/// Stores the settings as JSON under a single `UserDefaults` key.
struct UserDefaultsSettingsRepository: SettingsRepository {
    private static let key = "settings"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() async throws -> Settings? {
        try defaults.codable(forKey: Self.key)
    }

    func save(_ settings: Settings) async throws {
        try defaults.set(codable: settings, forKey: Self.key)
    }
}

extension SettingsStore {
    /// A store that loads from and persists to `defaults`.
    static func userDefaults(_ defaults: UserDefaults = .standard) -> SettingsStore {
        SettingsStore(
            repository: UserDefaultsSettingsRepository(defaults: defaults)
        )
    }
}

//
//  InMemorySettingsRepository.swift
//  CounterApp
//

/// Keeps the settings in memory only, for previews, tests, and anything that should not outlive the process.
final class InMemorySettingsRepository: SettingsRepository {
    private var stored: Settings?

    init(settings: Settings? = nil) {
        self.stored = settings
    }

    func load() async throws -> Settings? {
        stored
    }

    func save(_ settings: Settings) async throws {
        stored = settings
    }
}

extension SettingsStore {
    /// A store that starts with `settings` and keeps every change in memory.
    static func inMemory(_ settings: Settings = Settings()) -> SettingsStore {
        SettingsStore(
            repository: InMemorySettingsRepository(settings: settings),
            initialSettings: settings
        )
    }
}

//
//  AppContainer.swift
//  CounterApp
//

import Foundation

/// The composition root: owns the app-wide dependencies and wires them into every ViewModel.
///
/// Create one per app, or one per test or preview with its own `SettingsStore`.
final class AppContainer {
    private let settingsStore: SettingsStore

    init(settingsStore: SettingsStore = .userDefaults()) {
        self.settingsStore = settingsStore
    }

    /// Replaces any default settings with the persisted ones. Called as each window appears; repeated calls are harmless.
    func restore() async {
        await settingsStore.load()
    }
}

// MARK: - View Models

extension AppContainer {
    func makeMainViewModel() -> MainViewModel {
        MainViewModel(factory: self)
    }
}

extension AppContainer: ViewModelFactory {
    func makeCounterViewModel() -> CounterViewModel {
        CounterViewModel(settingsStore: settingsStore)
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(settingsStore: settingsStore)
    }
}

// MARK: - Stores

extension SettingsStore {
    /// A store that starts with `settings` and keeps every change in memory.
    static func inMemory(_ settings: Settings = Settings()) -> SettingsStore {
        SettingsStore(
            repository: InMemorySettingsRepository(settings: settings),
            initialSettings: settings
        )
    }

    /// A store that loads from and persists to `defaults`.
    static func userDefaults(_ defaults: UserDefaults = .standard) -> SettingsStore {
        SettingsStore(
            repository: UserDefaultsSettingsRepository(defaults: defaults)
        )
    }
}

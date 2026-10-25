//
//  AppContainer.swift
//  CounterApp
//

import Foundation

/// The composition root: owns the app-wide dependencies and wires them into every ViewModel.
///
/// Create one per app, or one per test or preview with its own `SettingsStore`.
final class AppContainer {
    /// The `UserDefaults` key the settings are stored under.
    static let settingsKey = "settings"

    /// The settings store shared by every ViewModel this container builds, so they all see the same settings.
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

extension AppContainer: ViewModelFactory {
    func makeMainViewModel() -> MainViewModel {
        MainViewModel(factory: self)
    }

    func makeCounterViewModel() -> CounterViewModel {
        CounterViewModel(settingsStore: settingsStore)
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(settingsStore: settingsStore)
    }
}

// MARK: - Stores

typealias SettingsStore = Store<Settings>

/// The app's ways to build a settings store. They pick the settings' defaults and storage key,
/// so call sites only choose where the settings live.
extension SettingsStore {
    /// A settings store that starts with `initialValue` and keeps every change in memory.
    static func inMemory(
        initialValue: Settings = Settings()
    ) -> SettingsStore {
        Store(
            initialValue: initialValue,
            repository: InMemoryRepository(initialValue)
        )
    }

    /// A settings store that starts with `initialValue`, then loads from and persists to `defaults`
    /// under `AppContainer.settingsKey`.
    static func userDefaults(
        initialValue: Settings = Settings(),
        defaults: UserDefaults = .standard
    ) -> SettingsStore {
        Store(
            initialValue: initialValue,
            repository: UserDefaultsRepository(
                key: AppContainer.settingsKey,
                defaults: defaults
            )
        )
    }
}

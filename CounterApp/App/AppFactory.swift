//
//  AppFactory.swift
//  CounterApp
//
//  Created by Workspace on 21/12/2025.
//

final class AppFactory {
    lazy var settingsStore = Self.makeSettingsStore()
    lazy var counterViewModel = Self.makeCounterViewModel(settingsStore: settingsStore)
    lazy var settingsViewModel = Self.makeSettingsViewModel(settings: settingsStore.settings)
}

// MARK: - Stores

extension AppFactory {
    static func makeSettingsStore() -> SettingsStore {
        SettingsStore()
    }
}

// MARK: - ViewModels

extension AppFactory {
    static func makeCounterViewModel(settingsStore: SettingsStore) -> CounterViewModel {
        CounterViewModel(settingsStore: settingsStore)
    }

    static func makeSettingsViewModel(settings: Settings) -> SettingsViewModel {
        SettingsViewModel(settings: settings)
    }
}

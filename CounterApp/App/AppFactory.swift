//
//  AppFactory.swift
//  CounterApp
//
//  Created by Workspace on 21/12/2025.
//

final class AppFactory {
    lazy var settingsStore = Self.makeSettingsStore()
    lazy var mainViewModel = Self.makeMainViewModel(settingsStore: settingsStore)
    lazy var counterViewModel = Self.makeCounterViewModel(settingsStore: settingsStore)
    lazy var settingsViewModel = Self.makeSettingsViewModel(settingsStore: settingsStore)
}

// MARK: - Stores

extension AppFactory {
    static func makeSettingsStore() -> SettingsStore {
        SettingsStore()
    }
}

// MARK: - ViewModels

extension AppFactory {
    static func makeMainViewModel(settingsStore: SettingsStore) -> MainViewModel {
        MainViewModel(settingsStore: settingsStore)
    }

    static func makeCounterViewModel(settingsStore: SettingsStore) -> CounterViewModel {
        CounterViewModel(settingsStore: settingsStore)
    }

    static func makeSettingsViewModel(settingsStore: SettingsStore) -> SettingsViewModel {
        SettingsViewModel(settingsStore: settingsStore)
    }
}

//
//  AppFactory.swift
//  CounterApp
//

final class AppFactory {
    lazy var settingsStore = Self.makeSettingsStore()
    lazy var mainViewModel = Self.makeMainViewModel(settingsStore: settingsStore)
    lazy var counterViewModel = Self.makeCounterViewModel(settingsStore: settingsStore)
    lazy var settingsViewModel = Self.makeSettingsViewModel(settingsStore: settingsStore)
}

// MARK: - Stores

extension AppFactory {
    static func makeSettingsStore() -> any Store<Settings> {
        SettingsStore()
    }
}

// MARK: - ViewModels

extension AppFactory {
    static func makeMainViewModel(settingsStore: any Store<Settings>) -> MainViewModel {
        MainViewModel(settingsStore: settingsStore)
    }

    static func makeCounterViewModel(settingsStore: any Store<Settings>) -> CounterViewModel {
        CounterViewModel(settingsStore: settingsStore)
    }

    static func makeSettingsViewModel(settingsStore: any Store<Settings>) -> SettingsViewModel {
        SettingsViewModel(settingsStore: settingsStore)
    }
}

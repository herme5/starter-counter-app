//
//  AppFactory.swift
//  CounterApp
//

final class AppFactory {
    private let settingsStore: SettingsStore

    init(settingsStore: SettingsStore = .userDefaults()) {
        self.settingsStore = settingsStore
    }

    func makeMainViewModel() -> MainViewModel {
        MainViewModel(factory: self)
    }

    /// Replaces the default settings with the persisted ones. Call once at launch.
    func loadSettings() async {
        await settingsStore.load()
    }
}

// MARK: - ViewModelFactory

extension AppFactory: ViewModelFactory {
    func makeCounterViewModel() -> CounterViewModel {
        CounterViewModel(settingsStore: settingsStore)
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(settingsStore: settingsStore)
    }
}

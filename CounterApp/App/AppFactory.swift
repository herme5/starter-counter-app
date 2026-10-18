//
//  AppFactory.swift
//  CounterApp
//

final class AppFactory {
    private let settingsStore: any Store<Settings>

    init(settingsStore: any Store<Settings> = SettingsStore()) {
        self.settingsStore = settingsStore
    }

    func makeMainViewModel() -> MainViewModel {
        MainViewModel(factory: self)
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

//
//  MainViewModel.swift
//  CounterApp
//

import Combine
import Foundation

class MainViewModel: ObservableObject {
    private let settingsStore: SettingsStore

    init(settingsStore: SettingsStore) {
        self.settingsStore = settingsStore
    }
}

extension MainViewModel {
    func makeCounterViewModel() -> CounterViewModel {
        AppFactory.makeCounterViewModel(settingsStore: settingsStore)
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        AppFactory.makeSettingsViewModel(settingsStore: settingsStore)
    }
}

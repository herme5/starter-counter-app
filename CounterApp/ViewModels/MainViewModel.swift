//
//  MainViewModel.swift
//  CounterApp
//

import Combine
import Foundation

class MainViewModel: ObservableObject {
    private let settingsStore: any Store<Settings>

    init(settingsStore: any Store<Settings>) {
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

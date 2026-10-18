//
//  MainViewModel.swift
//  CounterApp
//

import Foundation
import Observation

@Observable
final class MainViewModel {
    let counterViewModel: CounterViewModel
    var settingsViewModel: SettingsViewModel?

    @ObservationIgnored private let factory: any ViewModelFactory

    init(factory: any ViewModelFactory) {
        self.factory = factory
        self.counterViewModel = factory.makeCounterViewModel()
    }

    func showSettings() {
        settingsViewModel = factory.makeSettingsViewModel()
    }
}

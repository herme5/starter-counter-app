//
//  SettingsViewModel.swift
//  CounterApp
//

import Foundation
import Observation

@Observable
final class SettingsViewModel {
    @ObservationIgnored private let settingsStore: any Store<Settings>

    var counterMin: Int { didSet { save() } }
    var counterMax: Int { didSet { save() } }
    var counterStep: Int { didSet { save() } }
    private(set) var rangeErrorMessage: String?
    private(set) var stepErrorMessage: String?

    init(settingsStore: any Store<Settings>) {
        self.settingsStore = settingsStore

        let settings = settingsStore.object
        self.counterMin = settings.counterMin
        self.counterMax = settings.counterMax
        self.counterStep = settings.counterStep
    }

    func save() {
        if let settings = validateInputs() {
            settingsStore.object = settings
        }
    }

    func reset() {
        let settings = settingsStore.object
        self.counterMin = settings.counterMin
        self.counterMax = settings.counterMax
        self.counterStep = settings.counterStep
    }

    private func validateInputs() -> Settings? {
        let settings = Settings(
            counterMin: counterMin,
            counterMax: counterMax,
            counterStep: counterStep
        )
        do {
            try settings.validate()
            rangeErrorMessage = nil
            stepErrorMessage = nil
            return settings
        } catch {
            switch error {
            case .invalidRange:
                rangeErrorMessage = "Minimum must be less than Maximum"
            case .invalidStep:
                stepErrorMessage = "Step must be positive and non zero"
            }
            return nil
        }
    }
}

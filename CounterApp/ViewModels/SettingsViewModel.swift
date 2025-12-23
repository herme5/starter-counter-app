//
//  SettingsViewModel.swift
//  CounterApp
//

import Combine
import Foundation

class SettingsViewModel: ObservableObject {
    private let settingsStore: SettingsStore

    @Published var counterMin: Int { didSet { save() } }
    @Published var counterMax: Int { didSet { save() } }
    @Published var counterStep: Int { didSet { save() } }
    @Published var errorMessage: String = ""

    init(settingsStore: SettingsStore) {
        self.settingsStore = settingsStore

        let settings = settingsStore.settings
        self.counterMin = settings.counterMin
        self.counterMax = settings.counterMax
        self.counterStep = settings.counterStep
    }

    func save() {
        if let settings = validateInputs() {
            settingsStore.settings = settings
        }
    }

    func reset() {
        let settings = settingsStore.settings
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
            errorMessage = ""
            return settings
        } catch {
            switch error {
            case .invalidRange:
                errorMessage = "Minimum must be less than Maximum"
            case .invalidStep:
                errorMessage = "Step must be positive and non zero"
            }
            return nil
        }
    }
}

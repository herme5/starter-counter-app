//
//  SettingsViewModel.swift
//  CounterApp
//

import Foundation
import Observation

@Observable
final class SettingsViewModel: Identifiable {
    var counterMin: Int { didSet { save() } }
    var counterMax: Int { didSet { save() } }
    var counterStep: Int { didSet { save() } }
    private(set) var rangeErrorMessage: String?
    private(set) var stepErrorMessage: String?

    @ObservationIgnored private let settingsStore: any Store<Settings>

    init(settingsStore: any Store<Settings>) {
        self.settingsStore = settingsStore

        let settings = settingsStore.object
        self.counterMin = settings.counterMin
        self.counterMax = settings.counterMax
        self.counterStep = settings.counterStep
    }

    private func save() {
        let settings = Settings(
            counterMin: counterMin,
            counterMax: counterMax,
            counterStep: counterStep
        )
        let errors = settings.validationErrors
        rangeErrorMessage = errors.contains(.invalidRange) ? "Minimum must be less than Maximum" : nil
        stepErrorMessage = errors.contains(.invalidStep) ? "Step must be positive and non zero" : nil

        // The store rejects invalid settings; the messages above already explain why.
        try? settingsStore.save(settings)
    }
}

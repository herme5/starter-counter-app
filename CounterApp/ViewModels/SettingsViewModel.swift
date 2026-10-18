//
//  SettingsViewModel.swift
//  CounterApp
//

import Foundation
import Observation

@Observable
final class SettingsViewModel: Identifiable {
    /// The settings being edited. Valid edits are saved immediately; invalid ones stay local.
    var draft: Settings { didSet { save() } }

    var rangeErrorMessage: String? {
        draft.validationErrors.contains(.invalidRange) ? "Minimum must be less than Maximum" : nil
    }

    var stepErrorMessage: String? {
        draft.validationErrors.contains(.invalidStep) ? "Step must be positive and non zero" : nil
    }

    @ObservationIgnored private let settingsStore: any Store<Settings>

    init(settingsStore: any Store<Settings>) {
        self.settingsStore = settingsStore
        self.draft = settingsStore.object
    }

    private func save() {
        // The store rejects invalid settings; the error messages already explain why.
        try? settingsStore.save(draft)
    }
}

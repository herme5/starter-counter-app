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

    var rangeErrorMessage: LocalizedStringResource? {
        draft.validationErrors.contains(.invalidRange) ? "Minimum must be less than Maximum" : nil
    }

    var stepErrorMessage: LocalizedStringResource? {
        draft.validationErrors.contains(.invalidStep) ? "Step must be positive and non zero" : nil
    }

    var isDiscardAlertPresented = false

    @ObservationIgnored private let settingsStore: SettingsStore

    init(settingsStore: SettingsStore) {
        self.settingsStore = settingsStore
        self.draft = settingsStore.settings
    }

    /// Whether the settings can close now. Otherwise presents the discard alert.
    func requestDismiss() -> Bool {
        guard draft.isValid else {
            isDiscardAlertPresented = true
            return false
        }
        return true
    }

    /// Drops the invalid edits and goes back to the last valid settings, which are already saved.
    func discardInvalidChanges() {
        draft = settingsStore.settings
    }

    private func save() {
        // The store rejects invalid settings; the error messages already explain why.
        try? settingsStore.save(draft)
    }
}

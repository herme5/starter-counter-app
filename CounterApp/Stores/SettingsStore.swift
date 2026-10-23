//
//  SettingsStore.swift
//  CounterApp
//

import Combine
import OSLog

/// Holds the current settings, enforces their rules, and publishes every change.
///
/// `settings` and `settingsPublisher` only ever expose valid values, so subscribers never need to
/// validate what they receive. Where the settings are persisted is up to the `SettingsRepository`.
final class SettingsStore {
    private let repository: any SettingsRepository
    private let subject: CurrentValueSubject<Settings, Never>

    /// Set by the first change, so a slower `load()` cannot overwrite it.
    private var hasChanged = false
    private var lastWrite: Task<Void, Never>?

    var settings: Settings { subject.value }

    /// Emits the current value on subscription, then every change.
    var settingsPublisher: AnyPublisher<Settings, Never> { subject.eraseToAnyPublisher() }

    /// Starts with `initialSettings` until `load()` replaces them with the stored ones.
    init(repository: any SettingsRepository, initialSettings: Settings = Settings()) {
        self.repository = repository
        self.subject = CurrentValueSubject(initialSettings.isValid ? initialSettings : Settings())
    }

    /// Fetches and publishes the stored settings, unless they are missing or invalid, or the settings changed in the meantime.
    func load() async {
        let stored: Settings?
        do {
            stored = try await repository.load()
        } catch {
            AppLogger.store.error("Failed to load settings: \(error.localizedDescription)")
            return
        }

        guard !hasChanged, let stored, stored.isValid, stored != subject.value else { return }
        subject.send(stored)
    }

    /// Publishes `settings` right away and persists them in the background, in call order.
    ///
    /// Throws when `settings` break a rule. The current value is then left unchanged.
    func save(_ settings: Settings) throws(SettingsError) {
        try settings.validate()
        guard settings != subject.value else { return }

        hasChanged = true
        subject.send(settings)
        persist(settings)
    }

    /// Waits until every saved value has reached the repository.
    func flush() async {
        await lastWrite?.value
    }

    private func persist(_ settings: Settings) {
        let previousWrite = lastWrite
        lastWrite = Task { [repository] in
            await previousWrite?.value
            do {
                try await repository.save(settings)
            } catch {
                AppLogger.store.error("Failed to persist settings: \(error.localizedDescription)")
            }
        }
    }
}

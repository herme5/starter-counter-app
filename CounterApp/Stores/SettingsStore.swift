//
//  SettingsStore.swift
//  CounterApp
//

import Combine
import Foundation
import OSLog

final class SettingsStore: Store {
    private static let key = "settings"

    private let defaults: UserDefaults
    private let subject: CurrentValueSubject<Settings, Never>

    var object: Settings { subject.value }
    var objectPublisher: AnyPublisher<Settings, Never> { subject.eraseToAnyPublisher() }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let stored: Settings? = try? defaults.codable(forKey: Self.key)
        let initial = stored.flatMap { $0.isValid ? $0 : nil } ?? Settings()
        self.subject = CurrentValueSubject(initial)
    }

    func save(_ settings: Settings) throws {
        try settings.validate()
        guard settings != subject.value else { return }

        do {
            try defaults.set(codable: settings, forKey: Self.key)
        } catch {
            AppLogger.store.error("Failed to persist settings: \(error.localizedDescription)")
        }
        subject.send(settings)
    }
}

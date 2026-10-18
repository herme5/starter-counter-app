//
//  MockSettingsStore.swift
//  CounterApp
//

import Combine

/// In-memory store for previews and tests. Enforces the same rules as `SettingsStore`.
final class MockSettingsStore: Store {
    private let subject: CurrentValueSubject<Settings, Never>

    var object: Settings { subject.value }
    var objectPublisher: AnyPublisher<Settings, Never> { subject.eraseToAnyPublisher() }

    init(object: Settings = Settings()) {
        self.subject = CurrentValueSubject(object)
    }

    func save(_ settings: Settings) throws {
        try settings.validate()
        guard settings != subject.value else { return }
        subject.send(settings)
    }
}

//
//  MockSettingsStore.swift
//  CounterApp
//

import Combine

final class MockSettingsStore: Store {
    @Published var object: Settings
    var objectPublisher: Published<Settings>.Publisher { $object }

    init(object: Settings = Settings()) {
        self.object = object
    }
}

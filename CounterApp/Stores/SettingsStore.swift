//
//  SettingsStore.swift
//  CounterApp
//

import Combine
import Foundation

final class SettingsStore: Store {
    private static let key = "settings"
    private static let defaults = UserDefaults.standard

    @Published var object: Settings { didSet { Self.save(object) } }
    var objectPublisher: Published<Settings>.Publisher { $object }

    init() {
        self.object = Self.load() ?? Settings()
    }

    private static func load() -> Settings? {
        return try? defaults.codable(forKey: key)
    }

    private static func save(_ settings: Settings) {
        if let oldSettings = load(), oldSettings == settings {
            return
        }
        if !settings.isValid {
            return
        }
        try? defaults.set(codable: settings, forKey: key)
    }
}

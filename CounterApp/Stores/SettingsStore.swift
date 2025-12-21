//
//  SettingsStore.swift
//  CounterApp
//

import Combine
import Foundation

final class SettingsStore: ObservableObject {
    @Published private(set) var settings: Settings {
        didSet { Self.save(settings) }
    }

    private static let key = "settings"
    private static let defaults = UserDefaults.standard

    init() {
        self.settings = Self.load() ?? Settings()
    }

    private static func load() -> Settings? {
        return try? defaults.codable(forKey: key)
    }

    private static func save(_ settings: Settings) {
        try? defaults.set(codable: settings, forKey: key)
    }
}

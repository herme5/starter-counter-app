//
//  UserDefaultsRepository.swift
//  CounterApp
//

import Foundation

/// Stores the value as JSON under a single `UserDefaults` key, which must be unique to it.
struct UserDefaultsRepository<Value: Codable>: Repository {
    private let key: String
    private let defaults: UserDefaults

    init(key: String, defaults: UserDefaults = .standard) {
        self.key = key
        self.defaults = defaults
    }

    func load() async throws -> Value? {
        try defaults.codable(forKey: key)
    }

    func save(_ value: Value) async throws {
        try defaults.set(codable: value, forKey: key)
    }
}

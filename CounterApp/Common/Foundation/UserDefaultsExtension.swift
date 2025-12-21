//
//  UserDefaultsExtension.swift
//  CounterApp
//

import Foundation

extension UserDefaults {
    func set<T: Codable>(codable: T, forKey key: String) throws {
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(codable)
        set(encoded, forKey: key)
    }

    func codable<T: Codable>(forKey key: String) throws -> T? {
        guard let data = object(forKey: key) as? Data else { return nil }
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}

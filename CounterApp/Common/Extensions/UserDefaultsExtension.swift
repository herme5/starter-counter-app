//
//  UserDefaultsExtension.swift
//  CounterApp
//

import Foundation

extension UserDefaults {
    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()

    func set<T: Codable>(codable: T, forKey key: String) throws {
        let encoded = try Self.encoder.encode(codable)
        set(encoded, forKey: key)
    }

    func codable<T: Codable>(forKey key: String) throws -> T? {
        guard let data = object(forKey: key) as? Data else { return nil }
        return try Self.decoder.decode(T.self, from: data)
    }
}

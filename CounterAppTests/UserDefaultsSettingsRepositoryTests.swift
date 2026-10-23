//
//  UserDefaultsSettingsRepositoryTests.swift
//  CounterAppTests
//

import Foundation
import Testing
@testable import CounterApp

@Suite("UserDefaultsSettingsRepository")
final class UserDefaultsSettingsRepositoryTests {
    private let suiteName = "CounterAppTests.\(UUID().uuidString)"
    private let defaults: UserDefaults

    init() {
        defaults = UserDefaults(suiteName: suiteName)!
    }

    isolated deinit {
        defaults.removePersistentDomain(forName: suiteName)
    }

    @Test func loadReturnsNilWhenNothingIsStored() async throws {
        let sut = UserDefaultsSettingsRepository(defaults: defaults)
        #expect(try await sut.load() == nil)
    }

    @Test func savedSettingsLoadInANewInstance() async throws {
        let saved = Settings(counterMin: 5, counterMax: 50, counterStep: 5)

        try await UserDefaultsSettingsRepository(defaults: defaults).save(saved)

        #expect(try await UserDefaultsSettingsRepository(defaults: defaults).load() == saved)
    }
}

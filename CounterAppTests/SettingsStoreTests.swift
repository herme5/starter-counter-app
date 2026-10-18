//
//  SettingsStoreTests.swift
//  CounterAppTests
//

import Combine
import Foundation
import Testing
@testable import CounterApp

@Suite("SettingsStore")
struct SettingsStoreTests {
    private let suiteName = "CounterAppTests.\(UUID().uuidString)"
    private var defaults: UserDefaults { UserDefaults(suiteName: suiteName)! }

    @Test func startsWithDefaultsWhenNothingIsStored() {
        let sut = SettingsStore(defaults: defaults)
        #expect(sut.object == Settings())
    }

    @Test func savedSettingsPersistAcrossInstances() throws {
        let saved = Settings(counterMin: 5, counterMax: 50, counterStep: 5)

        try SettingsStore(defaults: defaults).save(saved)

        #expect(SettingsStore(defaults: defaults).object == saved)
    }

    @Test func invalidSettingsThrowAndLeaveValueUnchanged() {
        let sut = SettingsStore(defaults: defaults)

        #expect(throws: SettingsError.invalidRange) {
            try sut.save(Settings(counterMin: 10, counterMax: 0, counterStep: 1))
        }
        #expect(sut.object == Settings())
    }

    @Test func invalidStoredSettingsFallBackToDefaults() throws {
        try defaults.set(codable: Settings(counterMin: 0, counterMax: 10, counterStep: 0), forKey: "settings")

        #expect(SettingsStore(defaults: defaults).object == Settings())
    }

    @Test func publisherEmitsCurrentValueThenEachSave() throws {
        let sut = SettingsStore(defaults: defaults)
        let next = Settings(counterMin: 0, counterMax: 99, counterStep: 1)
        var received: [Settings] = []
        let cancellable = sut.objectPublisher.sink { received.append($0) }

        try sut.save(next)
        try sut.save(next)

        #expect(received == [Settings(), next])
        cancellable.cancel()
    }
}

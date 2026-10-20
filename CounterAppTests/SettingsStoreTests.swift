//
//  SettingsStoreTests.swift
//  CounterAppTests
//

import Combine
import Testing
@testable import CounterApp

@Suite("SettingsStore")
struct SettingsStoreTests {
    private struct FailingRepository: SettingsRepository {
        struct Failure: Error {}

        func load() async throws -> Settings? { throw Failure() }
        func save(_ settings: Settings) async throws { throw Failure() }
    }

    private let stored = Settings(counterMin: 5, counterMax: 50, counterStep: 5)

    @Test func startsWithInitialSettingsUntilLoaded() {
        let sut = SettingsStore(repository: InMemorySettingsRepository(settings: stored))
        #expect(sut.settings == Settings())
    }

    @Test func loadPublishesStoredSettings() async {
        let sut = SettingsStore(repository: InMemorySettingsRepository(settings: stored))

        await sut.load()

        #expect(sut.settings == stored)
    }

    @Test func loadKeepsInitialSettingsWhenNothingIsStored() async {
        let sut = SettingsStore(repository: InMemorySettingsRepository())

        await sut.load()

        #expect(sut.settings == Settings())
    }

    @Test func loadIgnoresInvalidStoredSettings() async {
        let invalid = Settings(counterMin: 0, counterMax: 10, counterStep: 0)
        let sut = SettingsStore(repository: InMemorySettingsRepository(settings: invalid))

        await sut.load()

        #expect(sut.settings == Settings())
    }

    @Test func loadKeepsInitialSettingsWhenRepositoryFails() async {
        let sut = SettingsStore(repository: FailingRepository())

        await sut.load()

        #expect(sut.settings == Settings())
    }

    @Test func loadDoesNotOverwriteAnEarlierSave() async throws {
        let sut = SettingsStore(repository: InMemorySettingsRepository(settings: stored))
        let edited = Settings(counterMin: 0, counterMax: 99, counterStep: 1)

        try sut.save(edited)
        await sut.load()

        #expect(sut.settings == edited)
    }

    @Test func savedSettingsReachTheRepository() async throws {
        let repository = InMemorySettingsRepository()
        let sut = SettingsStore(repository: repository)

        try sut.save(stored)
        await sut.flush()

        #expect(try await repository.load() == stored)
    }

    @Test func invalidSettingsThrowAndAreNotPersisted() async throws {
        let repository = InMemorySettingsRepository()
        let sut = SettingsStore(repository: repository)

        #expect(throws: SettingsError.invalidRange) {
            try sut.save(Settings(counterMin: 10, counterMax: 0, counterStep: 1))
        }
        await sut.flush()

        #expect(sut.settings == Settings())
        #expect(try await repository.load() == nil)
    }

    @Test func failedPersistenceKeepsTheNewValue() async throws {
        let sut = SettingsStore(repository: FailingRepository())

        try sut.save(stored)
        await sut.flush()

        #expect(sut.settings == stored)
    }

    @Test func publisherEmitsCurrentValueThenEachChange() throws {
        let sut = SettingsStore.inMemory()
        let next = Settings(counterMin: 0, counterMax: 99, counterStep: 1)
        var received: [Settings] = []
        let cancellable = sut.settingsPublisher.sink { received.append($0) }

        try sut.save(next)
        try sut.save(next)

        #expect(received == [Settings(), next])
        cancellable.cancel()
    }
}

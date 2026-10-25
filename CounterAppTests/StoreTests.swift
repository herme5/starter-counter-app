//
//  StoreTests.swift
//  CounterAppTests
//

import Combine
import Testing
@testable import CounterApp

@Suite("Store")
struct StoreTests {
    /// A value without rules, to show that any `Validatable` type gets a store.
    private struct Note: Equatable, Validatable {
        var text = ""
    }

    private struct FailingRepository: Repository {
        struct Failure: Error {}

        func load() async throws -> Settings? { throw Failure() }
        func save(_ value: Settings) async throws { throw Failure() }
    }

    private let stored = Settings(counterMin: 5, counterMax: 50, counterStep: 5)

    @Test func startsWithInitialSettingsUntilLoaded() {
        let sut = SettingsStore(initialValue: Settings(), repository: InMemoryRepository(stored))
        #expect(sut.value == Settings())
    }

    @Test func loadPublishesStoredSettings() async {
        let sut = SettingsStore(initialValue: Settings(), repository: InMemoryRepository(stored))

        await sut.load()

        #expect(sut.value == stored)
    }

    @Test func loadKeepsInitialSettingsWhenNothingIsStored() async {
        let sut = SettingsStore(initialValue: Settings(), repository: InMemoryRepository<Settings>())

        await sut.load()

        #expect(sut.value == Settings())
    }

    @Test func loadIgnoresInvalidStoredSettings() async {
        let invalid = Settings(counterMin: 0, counterMax: 10, counterStep: 0)
        let sut = SettingsStore(initialValue: Settings(), repository: InMemoryRepository(invalid))

        await sut.load()

        #expect(sut.value == Settings())
    }

    @Test func loadKeepsInitialSettingsWhenRepositoryFails() async {
        let sut = SettingsStore(initialValue: Settings(), repository: FailingRepository())

        await sut.load()

        #expect(sut.value == Settings())
    }

    @Test func loadDoesNotOverwriteAnEarlierSave() async throws {
        let sut = SettingsStore(initialValue: Settings(), repository: InMemoryRepository(stored))
        let edited = Settings(counterMin: 0, counterMax: 99, counterStep: 1)

        try sut.save(edited)
        await sut.load()

        #expect(sut.value == edited)
    }

    @Test func savedSettingsReachTheRepository() async throws {
        let repository = InMemoryRepository<Settings>()
        let sut = SettingsStore(initialValue: Settings(), repository: repository)

        try sut.save(stored)
        await sut.flush()

        #expect(try await repository.load() == stored)
    }

    @Test func invalidSettingsThrowAndAreNotPersisted() async throws {
        let repository = InMemoryRepository<Settings>()
        let sut = SettingsStore(initialValue: Settings(), repository: repository)

        #expect(throws: SettingsError.invalidRange) {
            try sut.save(Settings(counterMin: 10, counterMax: 0, counterStep: 1))
        }
        await sut.flush()

        #expect(sut.value == Settings())
        #expect(try await repository.load() == nil)
    }

    @Test func failedPersistenceKeepsTheNewValue() async throws {
        let sut = SettingsStore(initialValue: Settings(), repository: FailingRepository())

        try sut.save(stored)
        await sut.flush()

        #expect(sut.value == stored)
    }

    @Test func publisherEmitsCurrentValueThenEachChange() throws {
        let sut = SettingsStore.inMemory(initialValue: Settings())
        let next = Settings(counterMin: 0, counterMax: 99, counterStep: 1)
        var received: [Settings] = []
        let cancellable = sut.publisher.sink { received.append($0) }

        try sut.save(next)
        try sut.save(next)

        #expect(received == [Settings(), next])
        cancellable.cancel()
    }

    @Test func valueWithoutRulesIsAlwaysAccepted() async throws {
        let repository = InMemoryRepository<Note>()
        let sut = Store(initialValue: Note(), repository: repository)

        sut.save(Note(text: "Hello"))
        await sut.flush()

        #expect(sut.value == Note(text: "Hello"))
        #expect(try await repository.load() == Note(text: "Hello"))
    }
}

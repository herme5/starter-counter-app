//
//  SettingsSavePathTests.swift
//  CounterAppTests
//

import Foundation
import Testing
@testable import CounterApp

/// Exercises the real wiring: AppFactory, SettingsStore over UserDefaults, settings and counter ViewModels.
@Suite("Settings save path")
final class SettingsSavePathTests {
    private let suiteName = "CounterAppTests.\(UUID().uuidString)"
    private let defaults: UserDefaults
    private let settingsStore: SettingsStore
    private let mainViewModel: MainViewModel

    init() {
        defaults = UserDefaults(suiteName: suiteName)!
        settingsStore = .userDefaults(defaults)
        mainViewModel = AppContainer(settingsStore: settingsStore).makeMainViewModel()
    }

    isolated deinit {
        defaults.removePersistentDomain(forName: suiteName)
    }

    private func openSettings() throws -> SettingsViewModel {
        mainViewModel.showSettings()
        return try #require(mainViewModel.settingsViewModel)
    }

    /// What a fresh launch would read from UserDefaults, once pending writes are done.
    private func persistedSettings() async throws -> Settings? {
        await settingsStore.flush()
        return try await UserDefaultsSettingsRepository(defaults: defaults).load()
    }

    @Test func validEditIsPersistedAndReachesTheCounter() async throws {
        let counter = mainViewModel.counterViewModel
        for _ in 0..<8 { counter.increment() }
        #expect(counter.counter == 8)

        let settings = try openSettings()
        settings.draft.counterMax = 5

        #expect(try await persistedSettings() == Settings(counterMin: 0, counterMax: 5, counterStep: 1))
        #expect(counter.counter == 5)
    }

    @Test func invalidEditIsNotPersistedAndLeavesTheCounterAlone() async throws {
        let counter = mainViewModel.counterViewModel
        counter.increment()

        let settings = try openSettings()
        settings.draft.counterMin = 20

        #expect(settings.rangeErrorMessage != nil)
        #expect(try await persistedSettings() == nil)
        #expect(counter.counter == 1)
    }

    @Test func reopenedSettingsShowTheSavedValues() throws {
        let first = try openSettings()
        first.draft.counterStep = 4
        mainViewModel.dismissSettings()

        let second = try openSettings()

        #expect(second.draft.counterStep == 4)
    }

    @Test func persistedSettingsReachTheCounterAtLaunch() async throws {
        let saved = Settings(counterMin: 3, counterMax: 30, counterStep: 3)
        try await UserDefaultsSettingsRepository(defaults: defaults).save(saved)
        let appFactory = AppContainer(settingsStore: .userDefaults(defaults))
        let counter = appFactory.makeMainViewModel().counterViewModel

        await appFactory.restore()

        #expect(counter.counter == 3)
    }
}

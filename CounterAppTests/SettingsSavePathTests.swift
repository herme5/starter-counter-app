//
//  SettingsSavePathTests.swift
//  CounterAppTests
//

import Foundation
import Testing
@testable import CounterApp

/// Exercises the real wiring: AppFactory, live SettingsStore, settings and counter ViewModels.
@Suite("Settings save path")
final class SettingsSavePathTests {
    private let suiteName = "CounterAppTests.\(UUID().uuidString)"
    private let defaults: UserDefaults
    private let mainViewModel: MainViewModel

    init() {
        defaults = UserDefaults(suiteName: suiteName)!
        mainViewModel = AppFactory(settingsStore: SettingsStore(defaults: defaults)).makeMainViewModel()
    }

    deinit {
        defaults.removePersistentDomain(forName: suiteName)
    }

    private func openSettings() throws -> SettingsViewModel {
        mainViewModel.showSettings()
        return try #require(mainViewModel.settingsViewModel)
    }

    /// What a fresh launch would read from UserDefaults.
    private var persistedSettings: Settings {
        SettingsStore(defaults: defaults).object
    }

    @Test func validEditIsPersistedAndReachesTheCounter() throws {
        let counter = mainViewModel.counterViewModel
        for _ in 0..<8 { counter.increment() }
        #expect(counter.counter == 8)

        let settings = try openSettings()
        settings.draft.counterMax = 5

        #expect(persistedSettings == Settings(counterMin: 0, counterMax: 5, counterStep: 1))
        #expect(counter.counter == 5)
    }

    @Test func invalidEditIsNotPersistedAndLeavesTheCounterAlone() throws {
        let counter = mainViewModel.counterViewModel
        counter.increment()

        let settings = try openSettings()
        settings.draft.counterMin = 20

        #expect(settings.rangeErrorMessage != nil)
        #expect(persistedSettings == Settings())
        #expect(counter.counter == 1)
    }

    @Test func reopenedSettingsShowTheSavedValues() throws {
        let first = try openSettings()
        first.draft.counterStep = 4
        mainViewModel.dismissSettings()

        let second = try openSettings()

        #expect(second.draft.counterStep == 4)
    }
}

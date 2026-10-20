//
//  MainViewModelTests.swift
//  CounterAppTests
//

import Testing
@testable import CounterApp

@Suite("MainViewModel")
struct MainViewModelTests {
    private func makeSUT() -> MainViewModel {
        AppFactory(settingsStore: .inMemory()).makeMainViewModel()
    }

    @Test func startsWithSettingsHidden() {
        #expect(makeSUT().settingsViewModel == nil)
    }

    @Test func showSettingsPresentsAFreshViewModelEachTime() throws {
        let sut = makeSUT()

        sut.showSettings()
        let first = try #require(sut.settingsViewModel)
        sut.dismissSettings()
        sut.showSettings()
        let second = try #require(sut.settingsViewModel)

        #expect(first !== second)
    }

    @Test func dismissSettingsHidesTheSheet() {
        let sut = makeSUT()
        sut.showSettings()

        sut.dismissSettings()

        #expect(sut.settingsViewModel == nil)
    }
}

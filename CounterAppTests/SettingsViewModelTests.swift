//
//  SettingsViewModelTests.swift
//  CounterAppTests
//

import Testing
@testable import CounterApp

@Suite("SettingsViewModel")
struct SettingsViewModelTests {
    private func makeSUT() -> (SettingsViewModel, SettingsStore) {
        let store = SettingsStore.inMemory(Settings(counterMin: 0, counterMax: 10, counterStep: 1))
        return (SettingsViewModel(settingsStore: store), store)
    }

    @Test func startsWithStoredValuesAndNoErrors() {
        let (sut, _) = makeSUT()

        #expect(sut.draft.counterMin == 0)
        #expect(sut.draft.counterMax == 10)
        #expect(sut.draft.counterStep == 1)
        #expect(sut.rangeErrorMessage == nil)
        #expect(sut.stepErrorMessage == nil)
    }

    @Test func validEditIsSaved() {
        let (sut, store) = makeSUT()

        sut.draft.counterMax = 50

        #expect(store.settings.counterMax == 50)
    }

    @Test func invalidRangeShowsMessageAndIsNotSaved() {
        let (sut, store) = makeSUT()

        sut.draft.counterMin = 10

        #expect(sut.rangeErrorMessage != nil)
        #expect(sut.stepErrorMessage == nil)
        #expect(store.settings.counterMin == 0)
    }

    @Test func invalidStepShowsMessageAndIsNotSaved() {
        let (sut, store) = makeSUT()

        sut.draft.counterStep = 0

        #expect(sut.stepErrorMessage != nil)
        #expect(sut.rangeErrorMessage == nil)
        #expect(store.settings.counterStep == 1)
    }

    @Test func messagesClearIndependently() {
        let (sut, store) = makeSUT()
        sut.draft.counterMin = 20
        sut.draft.counterStep = 0
        #expect(sut.rangeErrorMessage != nil)
        #expect(sut.stepErrorMessage != nil)

        sut.draft.counterStep = 2

        #expect(sut.stepErrorMessage == nil)
        #expect(sut.rangeErrorMessage != nil)

        sut.draft.counterMax = 30

        #expect(sut.rangeErrorMessage == nil)
        #expect(store.settings == Settings(counterMin: 20, counterMax: 30, counterStep: 2))
    }
}

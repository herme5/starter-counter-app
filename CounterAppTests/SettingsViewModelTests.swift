//
//  SettingsViewModelTests.swift
//  CounterAppTests
//

import Testing
@testable import CounterApp

@Suite("SettingsViewModel")
struct SettingsViewModelTests {
    private func makeSUT() -> (SettingsViewModel, MockSettingsStore) {
        let store = MockSettingsStore(object: Settings(counterMin: 0, counterMax: 10, counterStep: 1))
        return (SettingsViewModel(settingsStore: store), store)
    }

    @Test func startsWithStoredValuesAndNoErrors() {
        let (sut, _) = makeSUT()

        #expect(sut.counterMin == 0)
        #expect(sut.counterMax == 10)
        #expect(sut.counterStep == 1)
        #expect(sut.rangeErrorMessage == nil)
        #expect(sut.stepErrorMessage == nil)
    }

    @Test func validEditIsSaved() {
        let (sut, store) = makeSUT()

        sut.counterMax = 50

        #expect(store.object.counterMax == 50)
    }

    @Test func invalidRangeShowsMessageAndIsNotSaved() {
        let (sut, store) = makeSUT()

        sut.counterMin = 10

        #expect(sut.rangeErrorMessage != nil)
        #expect(sut.stepErrorMessage == nil)
        #expect(store.object.counterMin == 0)
    }

    @Test func invalidStepShowsMessageAndIsNotSaved() {
        let (sut, store) = makeSUT()

        sut.counterStep = 0

        #expect(sut.stepErrorMessage != nil)
        #expect(sut.rangeErrorMessage == nil)
        #expect(store.object.counterStep == 1)
    }

    @Test func messagesClearIndependently() {
        let (sut, store) = makeSUT()
        sut.counterMin = 20
        sut.counterStep = 0
        #expect(sut.rangeErrorMessage != nil)
        #expect(sut.stepErrorMessage != nil)

        sut.counterStep = 2

        #expect(sut.stepErrorMessage == nil)
        #expect(sut.rangeErrorMessage != nil)

        sut.counterMax = 30

        #expect(sut.rangeErrorMessage == nil)
        #expect(store.object == Settings(counterMin: 20, counterMax: 30, counterStep: 2))
    }
}

//
//  CounterViewModelTests.swift
//  CounterAppTests
//

import Combine
import Testing
@testable import CounterApp

@Suite("CounterViewModel")
struct CounterViewModelTests {
    private func makeSUT(
        min: Int = 0, max: Int = 10, step: Int = 3
    ) -> (CounterViewModel, SettingsStore) {
        let store = SettingsStore.inMemory(Settings(counterMin: min, counterMax: max, counterStep: step))
        return (CounterViewModel(settingsStore: store), store)
    }

    private func overflows(
        of sut: CounterViewModel, during action: () -> Void
    ) -> [CounterViewModel.CounterError] {
        var received: [CounterViewModel.CounterError] = []
        let subscription = sut.overflow.sink { received.append($0) }
        action()
        subscription.cancel()
        return received
    }

    @Test func startsAtMinimum() {
        let (sut, _) = makeSUT(min: 2)
        #expect(sut.counter == 2)
    }

    @Test func incrementAddsStepAndStopsAtMaximum() {
        let (sut, _) = makeSUT(max: 10, step: 3)

        let received = overflows(of: sut) {
            sut.increment()
            #expect(sut.counter == 3)

            for _ in 0..<3 { sut.increment() }
            #expect(sut.counter == 10)
        }

        #expect(received.isEmpty)
    }

    @Test func incrementAtMaximumSignalsOverflow() {
        let (sut, _) = makeSUT(min: 0, max: 1, step: 1)
        sut.increment()

        let received = overflows(of: sut) { sut.increment() }

        #expect(sut.counter == 1)
        #expect(received == [.maximumOverflow])
    }

    @Test func decrementSubtractsStepAndStopsAtMinimum() {
        let (sut, _) = makeSUT(max: 10, step: 3)
        for _ in 0..<4 { sut.increment() }

        sut.decrement()
        #expect(sut.counter == 7)

        for _ in 0..<3 { sut.decrement() }
        #expect(sut.counter == 0)
    }

    @Test func decrementAtMinimumSignalsOverflow() {
        let (sut, _) = makeSUT()

        let received = overflows(of: sut) { sut.decrement() }

        #expect(sut.counter == 0)
        #expect(received == [.minimumOverflow])
    }

    @Test func repeatedOverflowIsSentEachTime() {
        let (sut, _) = makeSUT()

        let received = overflows(of: sut) {
            sut.decrement()
            sut.decrement()
        }

        #expect(received == [.minimumOverflow, .minimumOverflow])
    }

    @Test func resetReturnsToMinimum() {
        let (sut, _) = makeSUT(min: 1)
        sut.increment()

        sut.reset()

        #expect(sut.counter == 1)
    }

    @Test func newSettingsKeepValueThatStillFits() throws {
        let (sut, store) = makeSUT(max: 10, step: 3)
        sut.increment()

        try store.save(Settings(counterMin: 0, counterMax: 20, counterStep: 5))

        #expect(sut.counter == 3)
        sut.increment()
        #expect(sut.counter == 8)
    }

    @Test func newSettingsClampValueIntoRange() throws {
        let (sut, store) = makeSUT(max: 10, step: 3)
        for _ in 0..<3 { sut.increment() }

        try store.save(Settings(counterMin: 0, counterMax: 5, counterStep: 1))
        #expect(sut.counter == 5)

        try store.save(Settings(counterMin: 7, counterMax: 9, counterStep: 1))
        #expect(sut.counter == 7)
    }
}

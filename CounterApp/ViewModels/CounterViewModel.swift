//
//  CounterViewModel.swift
//  CounterApp
//

import Combine
import Foundation
import Observation

@Observable
final class CounterViewModel {
    enum CounterError: Error { case maximumOverflow, minimumOverflow }

    private(set) var counter: Int
    let overflowError = Signal<CounterError>()

    private var settings: Settings
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    private var counterStep: Int { settings.counterStep }
    private var counterMin: Int { settings.counterMin }
    private var counterMax: Int { settings.counterMax }

    init(settingsStore: any Store<Settings>) {
        self.settings = settingsStore.object
        self.counter = settingsStore.object.counterMin

        settingsStore.objectPublisher
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] settings in self?.apply(settings) }
            .store(in: &cancellables)
    }

    func increment() {
        guard counter < counterMax else {
            overflowError.send(.maximumOverflow)
            return
        }

        let delta = min(counterStep, counterMax - counter)
        counter += delta
    }

    func decrement() {
        guard counter > counterMin else {
            overflowError.send(.minimumOverflow)
            return
        }

        let delta = min(counterStep, counter - counterMin)
        counter -= delta
    }

    func reset() {
        counter = counterMin
    }

    /// Keeps the current value when it still fits, otherwise clamps it into the new range.
    private func apply(_ settings: Settings) {
        self.settings = settings
        counter = min(max(counter, counterMin), counterMax)
    }
}

//
//  CounterViewModel.swift
//  CounterApp
//

import Combine
import Foundation
import Observation

@Observable
final class CounterViewModel {
    enum CounterLimit { case maximum, minimum }

    private(set) var counter: Int
    @ObservationIgnored @Event<CounterLimit> var limitReached

    private var settings: Settings
    private var counterStep: Int { settings.counterStep }
    private var counterMin: Int { settings.counterMin }
    private var counterMax: Int { settings.counterMax }
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    init(settingsStore: SettingsStore) {
        self.settings = settingsStore.value
        self.counter = settingsStore.value.counterMin

        settingsStore.publisher
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] settings in self?.apply(settings) }
            .store(in: &cancellables)
    }

    func increment() {
        guard counter < counterMax else {
            _limitReached.send(.maximum)
            return
        }

        let delta = min(counterStep, counterMax - counter)
        counter += delta
    }

    func decrement() {
        guard counter > counterMin else {
            _limitReached.send(.minimum)
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

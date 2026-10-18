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
            .filter(\.isValid)
            .sink(receiveValue: onNewSettingsReceived)
            .store(in: &cancellables)
    }

    func onNewSettingsReceived(_ settings: Settings) {
        self.settings = settings
        self.counter = settings.counterMin
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
}

//
//  CounterViewModel.swift
//  CounterApp
//

import Combine
import Foundation

class CounterViewModel: ObservableObject {
    enum CounterError: Error { case maximumOverflow, minimumOverflow }
    private let resetDurationSec = 0.6
    private let settingsStore: SettingsStore

    @Published var counter: Int
    @Published private(set) var overflowError = Signal<CounterError>()
    @Published private(set) var settings: Settings

    private var resetWork: Task<Void, Never>?
    private var counterStep: Int { settingsStore.settings.counterStep }
    private var counterMin: Int { settingsStore.settings.counterMin }
    private var counterMax: Int { settingsStore.settings.counterMax }
    private var cancellables = Set<AnyCancellable>()

    init(settingsStore: SettingsStore) {
        self.settingsStore = settingsStore
        self.settings = settingsStore.settings
        self.counter = settingsStore.settings.counterMin

        settingsStore.$settings
            .filter(\.isValid)
            .sink(receiveValue: onNewSettingsReceived)
            .store(in: &cancellables)
    }

    func onNewSettingsReceived(_ settings: Settings) {
        self.settings = settings
        withYield { [weak self] in
            guard let self else { return }
            counter = settings.counterMin
        }
    }

    func increment() {
        // Yield for reset work before doing operations
        withYield { [weak self] in
            guard let self else { return }
            
            // Check overflow
            guard counter < counterMax else {
                overflowError.send(.maximumOverflow)
                return
            }
            
            // Increment by counter step or to maximum
            let delta = min(counterStep, counterMax - counter)
            counter += delta
        }
    }
    
    func decrement() {
        // Yield for reset work before doing operations
        withYield { [weak self] in
            guard let self else { return }
            
            // Check overflow
            guard counter > counterMin else {
                overflowError.send(.minimumOverflow)
                return
            }
            
            // Decrement by counter step or to minimum
            let delta = min(counterStep, counter)
            counter -= delta
        }
    }
    
    func reset() {
        // Avoid parallel resets, animation is short enough to just ignore the action
        guard resetWork == nil else { return }
        
        // Abort if the current value is already set to reset value
        guard counter > counterMin else { return }
        
        // Clamp to 9 to force animation to occur on the last digit
        let resetStep = min(counterStep, 9)
        
        // Compute distance from current to reset value, guaranteed to non-zero
        let distance = Double(counter / resetStep).rounded(.up)
        let intervalSecs = max(0.006, resetDurationSec / distance)
        
        resetWork = Task { [weak self] in
            guard let self else { return }
            defer { resetWork = nil }
            
            do {
                // Progressively decrement counter to reset value
                while counter > counterMin {
                    counter -= min(resetStep, counter)
                    try Task.checkCancellation()
                    try await Task.sleep(for: .seconds(intervalSecs))
                }
                // Progressively increment counter to reset value
                while counter < counterMin {
                    counter += min(resetStep, counter)
                    try Task.checkCancellation()
                    try await Task.sleep(for: .seconds(intervalSecs))
                }
            } catch {
                // Jump to reset value
                counter = counterMin
            }
        }
    }
    
    private func withYield(_ completion: @escaping () -> Void) {
        // Cancel any pending reset
        resetWork?.cancel()
        
        Task {
            // Give chance to jump to 0
            await Task.yield()
            
            // We are sure the counter is not in intermediate states
            completion()
        }
    }
}

extension CounterViewModel {

    func makeSettingsViewModel() -> SettingsViewModel {
        AppFactory.makeSettingsViewModel(settingsStore: settingsStore)
    }
}

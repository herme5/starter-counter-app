//
//  CounterViewModel.swift
//  CounterApp
//
//  Created by Workspace on 15/11/2025.
//

import Foundation
import Combine

@Observable
class CounterViewModel {
    enum CounterError: Error { case maximumOverflow, minimumOverflow }
    private let counterStep: UInt = 1
    private let counterMin: UInt = 0
    private let counterMax: UInt = 9999
    private let resetDurationSec = 0.6
    
    var counter: UInt = 0
    private(set) var overflowError = PublishedEvent<CounterError>()
    private var resetWork: Task<Void, Never>?
    
    func increment() {
        // Yield for reset work before doing operations
        withYield { [weak self] in
            guard let self else { return }
            
            // Check overflow
            guard counter < counterMax else {
                sendError(.minimumOverflow)
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
                sendError(.minimumOverflow)
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
        guard counter != .min else { return }
        
        // Compute distance from current to reset value, guaranteed to non-zero
        let distance = Double(counter / counterStep).rounded(.up)
        let intervalSecs = max(0.001, resetDurationSec / distance)
        
        resetWork = Task { [weak self] in
            guard let self else { return }
            defer { resetWork = nil }
            
            do {
                // Progressively decrement counter to reset value
                while counter > counterMin {
                    counter -= min(counterStep, counter)
                    try Task.checkCancellation()
                    try await Task.sleep(for: .seconds(intervalSecs))
                }
            } catch {
                // Jump to reset value
                counter = counterMin
            }
        }
    }
    
    private func sendError(_ error: CounterError) {
        overflowError.send(error)
    }
    
    private func withYield(_ completion: @escaping () -> Void) {
        // If there was cancelled pending reset...
        resetWork?.cancel()
        
        Task {
            // Give chance to jump to 0 before decrementation
            await Task.yield()
            
            // We are sure the counter is not in intermediate states
            completion()
        }
    }
}

struct PublishedEvent<T>: Publisher {
    typealias Output = T
    typealias Failure = Never
    private var subject = PassthroughSubject<T, Never>()
    func send(_ input: T) { subject.send(input) }
    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, T == S.Input { subject.receive(subscriber: subscriber) }
}

struct Signal<T>: Equatable {
    static func == (lhs: Signal<T>, rhs: Signal<T>) -> Bool { lhs.id == rhs.id }
    private var id = UUID()
    var value: T?
    mutating func send(_ input: T) {
        id = UUID()
        value = input
    }
}

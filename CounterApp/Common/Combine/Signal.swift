//
//  Signal.swift
//  CounterApp
//

import Combine
import Foundation

struct Signal<T>: Publisher, Identifiable {
    typealias Output = T
    typealias Failure = Never
    
    var id = UUID()
    private let subject = PassthroughSubject<T, Never>()
    
    mutating func send(_ input: T) {
        subject.send(input)
        id = UUID()
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, T == S.Input {
        subject.receive(subscriber: subscriber)
    }
}

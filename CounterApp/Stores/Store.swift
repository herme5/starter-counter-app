//
//  Store.swift
//  CounterApp
//

import Combine

protocol Store<T>: ObservableObject {
    associatedtype T
    var object: T { get set }
    var objectPublisher: Published<T>.Publisher { get }
}

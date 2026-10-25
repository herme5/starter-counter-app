//
//  Validatable.swift
//  CounterApp
//

/// A value with rules that a `Store` enforces before accepting it.
protocol Validatable {
    associatedtype ValidationError: Error

    /// Throws the first rule the value breaks.
    func validate() throws(ValidationError)
}

extension Validatable {
    var isValid: Bool { (try? validate()) != nil }
}

/// Values without rules conform for free, and saving them never throws.
extension Validatable where ValidationError == Never {
    func validate() {}
}

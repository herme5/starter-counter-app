//
//  Settings.swift
//  CounterApp
//

import Foundation

struct Settings: Codable {
    let counterMin: Int
    let counterMax: Int
    let counterStep: Int
}

extension Settings {
    static let `default` = Settings(counterMin: 0, counterMax: 10, counterStep: 1)
}

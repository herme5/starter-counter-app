//
//  Settings.swift
//  CounterApp
//

import Foundation

struct Settings: Codable {
    var counterMin: Int = 0
    var counterMax: Int = 10
    var counterStep: Int = 1
}

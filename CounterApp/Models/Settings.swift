//
//  Settings.swift
//  CounterApp
//

import Foundation

enum SettingsError: Error {
    case invalidRange
    case invalidStep
}

struct Settings: Codable {
    var counterMin: Int = 0
    var counterMax: Int = 10
    var counterStep: Int = 1

    var isValid: Bool {
        let result = try? validate()
        return result ?? false
    }

    @discardableResult
    func validate() throws(SettingsError) -> Bool {
        guard counterMin < counterMax else { throw .invalidRange }
        guard counterStep > 0 else { throw .invalidStep }
        return true
    }
}

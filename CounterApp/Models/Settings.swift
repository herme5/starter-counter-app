//
//  Settings.swift
//  CounterApp
//

import Foundation

enum SettingsError: Error, Hashable {
    case invalidRange
    case invalidStep
}

struct Settings: Codable, Equatable {
    var counterMin: Int = 0
    var counterMax: Int = 10
    var counterStep: Int = 1

    /// Every rule the settings currently break, so each one can be reported on its own.
    var validationErrors: Set<SettingsError> {
        var errors = Set<SettingsError>()
        if counterMin >= counterMax { errors.insert(.invalidRange) }
        if counterStep <= 0 { errors.insert(.invalidStep) }
        return errors
    }

    var isValid: Bool { validationErrors.isEmpty }

    func validate() throws(SettingsError) {
        if validationErrors.contains(.invalidRange) { throw .invalidRange }
        if validationErrors.contains(.invalidStep) { throw .invalidStep }
    }
}

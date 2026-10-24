//
//  AppLogger.swift
//  CounterApp
//

import OSLog

enum AppLogger {
    static let store: Logger = create(category: "store")
}

fileprivate extension AppLogger {
    static let subsystem = Bundle.main.bundleIdentifier ?? "CounterApp"

    static func create(category: String) -> Logger {
        Logger(subsystem: subsystem, category: category)
    }
}

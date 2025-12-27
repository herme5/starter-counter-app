//
//  AppLogger.swift
//  CounterApp
//

import OSLog

enum AppLogger {
    static let main: Logger = create(category: "main")
    static let store: Logger = create(category: "store")
}

fileprivate extension AppLogger {
    static func create(category: String) -> Logger {
        Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "CounterApp",
            category: category
        )
    }
}

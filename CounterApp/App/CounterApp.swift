//
//  CounterApp.swift
//  CounterApp
//

import SwiftUI

@main
struct CounterApp: App {
    private let appFactory = AppFactory()

    var body: some Scene {
        WindowGroup {
            MainView(viewModel: appFactory.mainViewModel)
        }
    }
}

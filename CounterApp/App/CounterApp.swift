//
//  CounterApp.swift
//  CounterApp
//

import SwiftUI

@main
struct CounterApp: App {
    @State private var mainViewModel = AppFactory().makeMainViewModel()

    var body: some Scene {
        WindowGroup {
            MainView(viewModel: mainViewModel)
        }
    }
}

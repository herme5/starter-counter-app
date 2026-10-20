//
//  CounterApp.swift
//  CounterApp
//

import SwiftUI

@main
struct CounterApp: App {
    private let appFactory: AppFactory
    @State private var mainViewModel: MainViewModel

    init() {
        let appFactory = AppFactory()
        self.appFactory = appFactory
        _mainViewModel = State(initialValue: appFactory.makeMainViewModel())
    }

    var body: some Scene {
        WindowGroup {
            MainView(viewModel: mainViewModel)
                .task { await appFactory.loadSettings() }
        }
    }
}

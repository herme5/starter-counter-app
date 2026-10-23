//
//  CounterApp.swift
//  CounterApp
//

import SwiftUI

@main
struct CounterApp: App {
    private let container = AppContainer()
    @State private var mainViewModel: MainViewModel

    init() {
        _mainViewModel = State(initialValue: container.makeMainViewModel())
    }

    var body: some Scene {
        WindowGroup {
            MainView(viewModel: mainViewModel)
                .task { await container.restore() }
        }
    }
}

//
//  MainView.swift
//  CounterApp
//

import SwiftUI

struct MainView: View {
    @State private var viewModel: MainViewModel

    init(viewModel: MainViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            ZStack {
                // Background
                Color.primaryBackground
                    .ignoresSafeArea()
                
                CounterView(viewModel: viewModel.counterViewModel)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingsToolBarItem
                }
                .sharedBackgroundVisibility(.hidden)
            }
            .sheet(item: $viewModel.settingsViewModel) { settingsViewModel in
                SettingsView(viewModel: settingsViewModel)
            }
        }
    }

    var settingsToolBarItem: some View {
        Button(action: viewModel.showSettings) {
            Image(systemName: "gearshape.fill")
                .resizable()
                .frame(width: 32, height: 32)
        }
        .foregroundStyle(.primaryForeground)
    }
}

#if DEBUG
#Preview {
    let appFactory = AppFactory(settingsStore: MockSettingsStore())
    MainView(viewModel: appFactory.makeMainViewModel())
}
#endif

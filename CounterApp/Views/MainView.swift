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
            .sheet(item: settingsSheetBinding) { settingsViewModel in
                SettingsView(viewModel: settingsViewModel)
            }
        }
    }

    /// Reads the presented ViewModel and routes dismissal, such as a swipe down, through the ViewModel.
    private var settingsSheetBinding: Binding<SettingsViewModel?> {
        Binding(
            get: { viewModel.settingsViewModel },
            set: { newValue in
                if newValue == nil { viewModel.dismissSettings() }
            }
        )
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

#Preview {
    let appFactory = AppFactory(settingsStore: .inMemory())
    MainView(viewModel: appFactory.makeMainViewModel())
}

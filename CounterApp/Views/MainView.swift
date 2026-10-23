//
//  MainView.swift
//  CounterApp
//

import SwiftUI

struct MainView: View {
    private let viewModel: MainViewModel

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
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
                    settingsToolbarItem
                }
                .sharedBackgroundVisibility(.hidden)
            }
            .sheet(item: settingsSheetBinding) { settingsViewModel in
                SettingsView(viewModel: settingsViewModel)
            }
        }
    }

    private var settingsToolbarItem: some View {
        Button(action: viewModel.showSettings) {
            Image(systemName: "gearshape.fill")
                .resizable()
                .frame(width: 32, height: 32)
        }
        .foregroundStyle(.primaryForeground)
        .accessibilityLabel("Settings")
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
}

#Preview {
    let container = AppContainer(settingsStore: .inMemory())
    MainView(viewModel: container.makeMainViewModel())
}

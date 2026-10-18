//
//  MainView.swift
//  CounterApp
//

import SwiftUI

struct MainView: View {
    @State private var viewModel: MainViewModel
    @State private var showSettings = false

    init(viewModel: MainViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.primaryBackground
                    .ignoresSafeArea()
                
                CounterView(viewModel: viewModel.makeCounterViewModel())
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingsToolBarItem
                }
                .sharedBackgroundVisibility(.hidden)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: viewModel.makeSettingsViewModel())
            }
        }
    }

    var settingsToolBarItem: some View {
        Button(action: { showSettings = true }) {
            Image(systemName: "gearshape.fill")
                .resizable()
                .frame(width: 32, height: 32)
        }
        .foregroundStyle(.primaryForeground)
    }
}

#Preview {
    let appFactory = AppFactory()
    MainView(viewModel: appFactory.mainViewModel)
}


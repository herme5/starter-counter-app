//
//  ViewModelFactory.swift
//  CounterApp
//

/// Builds the ViewModels that a parent ViewModel hands to its child views.
protocol ViewModelFactory {
    func makeCounterViewModel() -> CounterViewModel
    func makeSettingsViewModel() -> SettingsViewModel
}

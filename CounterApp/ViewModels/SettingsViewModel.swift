//
//  SettingsViewModel.swift
//  CounterApp
//

import Combine
import Foundation

class SettingsViewModel: ObservableObject {
    @Published var settings: Settings { didSet { validate() } }
    var errorMessage: String = ""
    
    init(settings: Settings = Settings()) {
        self.settings = settings
    }
    
    private func validate() {
        Task {
            if settings.counterMin >= settings.counterMax {
                errorMessage = "Minimum must be less than Maximum"
            } else {
                errorMessage = ""
            }
        }
    }
}

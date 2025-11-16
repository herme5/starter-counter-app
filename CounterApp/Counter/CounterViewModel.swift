//
//  CounterViewModel.swift
//  CounterApp
//
//  Created by Workspace on 15/11/2025.
//

import Foundation

extension CounterView {
    @Observable
    class ViewModel {
        
        var counter: Int = 0
        
        func increment() { counter += 1 }
        
        func decrement() { counter -= 1 }
    }
}

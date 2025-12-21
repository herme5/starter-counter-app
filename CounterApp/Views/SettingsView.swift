//
//  SettingsView.swift
//  CounterApp
//

import SwiftUI


struct SettingsView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @State var viewModel: SettingsViewModel
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                Form {

                    Section(
                        content: {
                            HStack {
                                Text("Minimum Value")
                                Spacer()
                                TextField("Min", value: $viewModel.settings.counterMin, formatter: NumberFormatter())
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 80)
                            }
                            HStack {
                                Text("Maximum Value")
                                Spacer()
                                TextField("Max", value: $viewModel.settings.counterMax, formatter: NumberFormatter())
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 80)
                            }
                        },
                        header: { Text("Range") },
                        footer: { if let errorMessage { Text(errorMessage) } }
                    )

                    Section(
                        content: {
                            HStack {
                                Text("Increment Step")
                                Spacer()
                                TextField("Step", value: $viewModel.settings.counterStep, formatter: NumberFormatter())
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 80)
                            }
                        },
                        header: { Text("Increment") }
                    )
                }
                .navigationTitle("Settings")
                .onChange(of: viewModel.errorMessage) { _, newValue in
                    withAnimation {
                        self.errorMessage = newValue.isEmpty ? nil : newValue
                    }
                }

            }
        }
    }
}

#Preview {
    let viewModel = SettingsViewModel()
    SettingsView(viewModel: viewModel)
}

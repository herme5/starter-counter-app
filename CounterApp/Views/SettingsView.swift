//
//  SettingsView.swift
//  CounterApp
//

import SwiftUI


struct SettingsView: View {
    enum Field: Hashable {
        case minimumValue, maximumValue, incrementStep
    }

    @StateObject var viewModel: SettingsViewModel
    @FocusState private var focusedField: Field?

    var body: some View {
        NavigationView {
            Form {
                Section(
                    content: {
                        HStack {
                            Text("Minimum value")
                            TextField("Min", value: $viewModel.counterMin, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .focused($focusedField, equals: .minimumValue)
                        }
                        HStack {
                            Text("Maximum value")
                            TextField("Max", value: $viewModel.counterMax, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .focused($focusedField, equals: .maximumValue)
                        }
                    },
                    header: { Text("Range") },
                    footer: {
                        if let message = viewModel.rangeErrorMessage {
                            Text(message)
                        }
                    }
                )

                Section(
                    content: {
                        HStack {
                            Text("Increment step")
                            TextField("Step", value: $viewModel.counterStep, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .focused($focusedField, equals: .incrementStep)
                        }
                    },
                    header: { Text("Increment") },
                    footer: {
                        if let message = viewModel.stepErrorMessage {
                            Text(message)
                        }
                    }
                )
            }
            .animation(.default, value: viewModel.rangeErrorMessage)
            .animation(.default, value: viewModel.stepErrorMessage)
            .navigationTitle("Settings")
            .toolbar { keyboardItemGroup }
        }
    }

    var keyboardItemGroup: ToolbarItemGroup<some View> {
        ToolbarItemGroup(placement: .keyboard) {
            HStack {
                Spacer()

                Button(action: {
                    switch focusedField {
                    case .minimumValue:
                        viewModel.counterMin += 1
                    case .maximumValue:
                        viewModel.counterMax += 1
                    case .incrementStep:
                        viewModel.counterStep += 1
                    case nil: break
                    }
                }) {
                    Image(systemName: "plus.circle")
                }
                .foregroundStyle(.primaryForeground)

                Button(action: {
                    switch focusedField {
                    case .minimumValue:
                        viewModel.counterMin -= 1
                    case .maximumValue:
                        viewModel.counterMax -= 1
                    case .incrementStep:
                        viewModel.counterStep -= 1
                    case nil: break
                    }
                }) {
                    Image(systemName: "minus.circle")
                }
                .foregroundStyle(.primaryForeground)

                Button(action: {
                    focusedField = nil
                }) {
                    Image(systemName: "checkmark.circle")
                }
                .foregroundStyle(.primaryForeground)
            }
        }
    }
}

#Preview {
    let appFactory = AppFactory()
    SettingsView(viewModel: appFactory.settingsViewModel)
}

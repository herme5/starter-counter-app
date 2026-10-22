//
//  SettingsView.swift
//  CounterApp
//

import SwiftUI

struct SettingsView: View {
    enum Field: Hashable {
        case minimumValue, maximumValue, incrementStep

        var title: LocalizedStringResource {
            switch self {
            case .minimumValue: "Minimum value"
            case .maximumValue: "Maximum value"
            case .incrementStep: "Increment step"
            }
        }

        var placeholder: LocalizedStringResource {
            switch self {
            case .minimumValue: "Min"
            case .maximumValue: "Max"
            case .incrementStep: "Step"
            }
        }

        /// The setting this field edits.
        var keyPath: WritableKeyPath<Settings, Int> {
            switch self {
            case .minimumValue: \.counterMin
            case .maximumValue: \.counterMax
            case .incrementStep: \.counterStep
            }
        }
    }

    let keyboardItemHSpacing: CGFloat = 16
    let keyboardItemBottomSpace: CGFloat = 12
    let keyboardItemBarHeight: CGFloat = 44

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SettingsViewModel
    @FocusState private var focusedField: Field?

    init(viewModel: SettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(
                    content: {
                        numberRow(.minimumValue)
                        numberRow(.maximumValue)
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
                        numberRow(.incrementStep)
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
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .confirm) { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if focusedField != nil {
                    keyboardItemGroup
                        .padding(.bottom, keyboardItemBottomSpace)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.default, value: focusedField)
        }
    }

    var keyboardItemGroup: some View {
        HStack(spacing: keyboardItemHSpacing) {
            Button(action: { adjustFocusedField(by: 1) }) {
                Image(systemName: "plus")
                    .frame(height: keyboardItemBarHeight)
            }
            Button(action: { adjustFocusedField(by: -1) }) {
                Image(systemName: "minus")
                    .frame(height: keyboardItemBarHeight)
            }
            Button(action: { focusedField = nil }) {
                Image(systemName: "keyboard.chevron.compact.down")
                    .frame(height: keyboardItemBarHeight)
            }
        }
        .padding(.horizontal, keyboardItemHSpacing)
        .foregroundStyle(.primaryForeground)
        .glassEffect()
    }

    private func numberRow(_ field: Field) -> some View {
        @Bindable var viewModel = viewModel

        return HStack {
            Text(field.title)
            TextField(field.placeholder, value: $viewModel.draft[dynamicMember: field.keyPath], formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .focused($focusedField, equals: field)
        }
        .contentShape(.rect)
        .onTapGesture { focusedField = field }
    }

    private func adjustFocusedField(by delta: Int) {
        guard let keyPath = focusedField?.keyPath else { return }
        viewModel.draft[keyPath: keyPath] += delta
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel(settingsStore: .inMemory()))
}

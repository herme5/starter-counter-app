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

    private let keyboardItemHSpacing: CGFloat = 16
    private let keyboardItemBottomSpace: CGFloat = 12
    private let keyboardItemBarHeight: CGFloat = 44

    @Environment(\.dismiss) private var dismiss
    @Bindable private var viewModel: SettingsViewModel
    @FocusState private var focusedField: Field?

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
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
                    Button(role: .confirm) {
                        if viewModel.requestDismiss() { dismiss() }
                    }
                }
            }
            .interactiveDismissDisabled(!viewModel.draft.isValid)
            .alert("Invalid Settings", isPresented: $viewModel.isDiscardAlertPresented) {
                Button("Keep Editing", role: .cancel) {}
                Button("Discard Invalid Changes", role: .destructive) {
                    viewModel.discardInvalidChanges()
                    dismiss()
                }
            } message: {
                Text("Some values are invalid. Discard them and keep the last valid settings?")
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

    private var keyboardItemGroup: some View {
        HStack(spacing: keyboardItemHSpacing) {
            keyboardItem("Increase value", systemImage: "plus") { adjustFocusedField(by: 1) }
            keyboardItem("Decrease value", systemImage: "minus") { adjustFocusedField(by: -1) }
            keyboardItem("Hide keyboard", systemImage: "keyboard.chevron.compact.down") { focusedField = nil }
        }
        .padding(.horizontal, keyboardItemHSpacing)
        .foregroundStyle(.primaryForeground)
        .glassEffect()
    }

    private func keyboardItem(
        _ title: LocalizedStringResource,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label { Text(title) } icon: { Image(systemName: systemImage) }
                .labelStyle(.iconOnly)
                .frame(height: keyboardItemBarHeight)
        }
    }

    private func numberRow(_ field: Field) -> some View {
        HStack {
            Text(field.title)
            TextField(field.placeholder, value: $viewModel.draft[dynamicMember: field.keyPath], format: .number)
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

//
//  EditPreferenceView.swift
//  JarvisSDK
//
//  View for editing a preference value
//

import SwiftUI
import JarvisDesignSystem
import JarvisPreferencesDomain

/// View for editing a preference
struct EditPreferenceView: View {
    let preference: Preference
    @State private var editedValue: String
    @Environment(\.dismiss) private var dismiss

    init(preference: Preference) {
        self.preference = preference
        self._editedValue = State(initialValue: String(describing: preference.value))
    }

    var body: some View {
        Form {
            Section(header: Text("Key")) {
                Text(preference.key)
                    .foregroundColor(DSColor.Neutral.neutral100)
            }

            Section(header: Text("Type")) {
                Text(preference.type)
                    .foregroundColor(DSColor.Neutral.neutral80)
            }

            Section(header: Text("Value")) {
                TextField("Value", text: $editedValue)
                    .textFieldStyle(.roundedBorder)
            }

            Section(header: Text("Source")) {
                Text(preference.source.rawValue)
                    .foregroundColor(DSColor.Neutral.neutral80)
            }

            if let suite = preference.suiteName {
                Section(header: Text("Suite Name")) {
                    Text(suite)
                        .foregroundColor(DSColor.Neutral.neutral80)
                }
            }
        }
        .navigationTitle("Edit Preference")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                DSButton(
                    "Save",
                    style: .primary,
                    size: .small,
                    action: savePreference
                )
            }
            ToolbarItem(placement: .cancellationAction) {
                DSButton(
                    "Cancel",
                    style: .ghost,
                    size: .small,
                    action: { dismiss() }
                )
            }
        }
    }

    private func savePreference() {
        // TODO: Implement save functionality via UpdatePreferenceUseCase
        dismiss()
    }
}

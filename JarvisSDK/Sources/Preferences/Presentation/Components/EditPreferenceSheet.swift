//
//  EditPreferenceSheet.swift
//  JarvisSDK
//
//  Created by Jose Luis Dumas Leon   on 7/11/25.
//

import SwiftUI
import DesignSystem
import JarvisPreferencesDomain

// MARK: - Edit Preference Sheet

public struct EditPreferenceSheet: View {
    let preference: Preference
    let onSave: (Any) -> Void
    let onDismiss: () -> Void

    @State private var value: String

    public init(preference: Preference, onSave: @escaping (Any) -> Void, onDismiss: @escaping () -> Void) {
        self.preference = preference
        self.onSave = onSave
        self.onDismiss = onDismiss
        _value = State(initialValue: String(describing: preference.value))
    }

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Preference Details")) {
                    LabeledContent("Key", value: preference.key)
                    LabeledContent("Type", value: preference.type)
                    LabeledContent("Source", value: preference.source.rawValue)
                    if let suite = preference.suiteName {
                        LabeledContent("Suite", value: suite)
                    }
                }

                Section(header: Text("Value")) {
                    TextField("Value", text: $value)
                        #if os(iOS)
                        .autocapitalization(.none)
                        #endif
                }

                Section {
                    Button("Save Changes") {
                        if !value.isEmpty {
                            if let parsedValue = parseValue(value, type: preference.type) {
                                onSave(parsedValue)
                            }
                        }
                    }
                    .disabled(value.isEmpty)
                }
            }
            .navigationTitle("Edit Preference")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
            }
        }
    }

    private func parseValue(_ value: String, type: String) -> Any? {
        let lowercaseType = type.lowercased()

        if lowercaseType.contains("string") || lowercaseType.contains("nsstring") {
            return value
        } else if lowercaseType.contains("bool") {
            return Bool(value)
        } else if lowercaseType.contains("int") && !lowercaseType.contains("float") {
            return Int(value)
        } else if lowercaseType.contains("float") || lowercaseType.contains("cgfloat") {
            return Float(value)
        } else if lowercaseType.contains("double") {
            return Double(value)
        } else if lowercaseType.contains("data") {
            return value.data(using: .utf8)
        } else if lowercaseType.contains("array") {
            return value.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        } else if lowercaseType.contains("dict") {
            return ["value": value]
        } else {
            return value
        }
    }
}

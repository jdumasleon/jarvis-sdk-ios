import SwiftUI
import DesignSystem
import JarvisPreferencesDomain

// MARK: - Add Preference Sheet

public struct AddPreferenceSheet: View {
    let selectedSource: PreferenceFilter
    let onSave: (String, Any, String) -> Void
    let onDismiss: () -> Void

    @State private var key: String = ""
    @State private var value: String = ""
    @State private var selectedType: String = "String"

    let types = ["String", "Boolean", "Integer", "Float", "Double", "Array", "Dictionary", "Data"]

    public init(
        selectedSource: PreferenceFilter,
        onSave: @escaping (String, Any, String) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.selectedSource = selectedSource
        self.onSave = onSave
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Preference Details")) {
                    TextField("Key", text: $key)
                        #if os(iOS)
                        .autocapitalization(.none)
                        #endif

                    Picker("Type", selection: $selectedType) {
                        ForEach(types, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }

                    TextField(placeholderForType(selectedType), text: $value)
                        #if os(iOS)
                        .autocapitalization(.none)
                        #endif
                }

                Section {
                    Button("Add Preference") {
                        if !key.isEmpty && !value.isEmpty {
                            if let parsedValue = parseValue(value, type: selectedType) {
                                onSave(key, parsedValue, selectedType)
                            }
                        }
                    }
                    .disabled(key.isEmpty || value.isEmpty)
                }
            }
            .navigationTitle("Add Preference")
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

    private func placeholderForType(_ type: String) -> String {
        switch type {
        case "String": return "Enter string value"
        case "Boolean": return "true or false"
        case "Integer": return "123"
        case "Float": return "123.45"
        case "Double": return "123.456789"
        case "Array": return "[\"item1\", \"item2\"]"
        case "Dictionary": return "{\"key\": \"value\"}"
        case "Data": return "Enter text to convert to data"
        default: return "Enter value"
        }
    }

    private func parseValue(_ value: String, type: String) -> Any? {
        switch type {
        case "String":
            return value
        case "Boolean":
            return Bool(value)
        case "Integer":
            return Int(value)
        case "Float":
            return Float(value)
        case "Double":
            return Double(value)
        case "Data":
            return value.data(using: .utf8)
        case "Array":
            // Simple array parsing - in production you'd use JSONDecoder
            return value.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        case "Dictionary":
            // Simple dict - in production you'd use JSONDecoder
            return ["value": value]
        default:
            return value
        }
    }
}

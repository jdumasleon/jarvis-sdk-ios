//
//  PreferencesScreen.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import SwiftUI

struct PreferencesScreen: View {
    @ObservedObject var viewModel: PreferencesViewModel
    @State private var showingAddPreference = false

    var body: some View {
        NavigationView {
            content
                .navigationTitle("Preferences")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add") {
                            showingAddPreference.toggle()
                        }
                    }
                }
                .sheet(isPresented: $showingAddPreference) {
                    AddPreferenceView(viewModel: viewModel)
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.uiState {
        case .idle, .loading:
            ProgressView("Loading preferences...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .success(let data):
            successContent(data: data)
                .refreshable {
                    viewModel.onEvent(.RefreshPreferences)
                }

        case .error(let error):
            errorView(error: error)
        }
    }

    private func successContent(data: PreferencesUiData) -> some View {
        VStack(spacing: 0) {
            // Search Bar
            searchSection(data: data)

            // Storage Type Tabs
            storageTypeSection(data: data)

            // Preferences List
            if data.filteredPreferences.isEmpty {
                emptyStateView(data: data)
            } else {
                preferencesList(data: data)
            }
        }
    }

    private func searchSection(data: PreferencesUiData) -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search preferences...", text: Binding(
                get: { data.searchQuery },
                set: { viewModel.onEvent(.UpdateSearchQuery($0)) }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())

            if !data.searchQuery.isEmpty {
                Button("Clear") {
                    viewModel.onEvent(.ClearSearch)
                }
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }

    private func storageTypeSection(data: PreferencesUiData) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(PreferenceStorageType.allCases, id: \.self) { storageType in
                    storageTypeChip(storageType: storageType, data: data)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }

    private func storageTypeChip(storageType: PreferenceStorageType, data: PreferencesUiData) -> some View {
        let isSelected = data.selectedStorageType == storageType
        let count = data.preferences.filter { $0.storageType == storageType }.count

        return Button(action: {
            viewModel.onEvent(.SelectStorageType(storageType))
        }) {
            VStack(spacing: 4) {
                Text(storageType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)

                Text("\(count)")
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }

    private func emptyStateView(data: PreferencesUiData) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "gearshape.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Preferences Found")
                .font(.headline)
                .foregroundColor(.gray)

            Text("Try adjusting your search or selecting a different storage type")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Reset Filters") {
                viewModel.onEvent(.ClearSearch)
                viewModel.onEvent(.SelectStorageType(.userDefaults))
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func preferencesList(data: PreferencesUiData) -> some View {
        List {
            // Storage Type Description
            storageDescriptionSection(data: data)

            // Preferences
            ForEach(data.filteredPreferences) { preference in
                PreferenceRowView(preference: preference, viewModel: viewModel)
            }
        }
        .listStyle(PlainListStyle())
    }

    private func storageDescriptionSection(data: PreferencesUiData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: storageTypeIcon(data.selectedStorageType))
                    .foregroundColor(.blue)
                Text(data.selectedStorageType.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            Text(storageTypeDescription(data.selectedStorageType))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
        .listRowSeparator(.hidden)
    }

    private func errorView(error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text("Error Loading Preferences")
                .font(.headline)

            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                viewModel.onEvent(.RefreshPreferences)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func storageTypeIcon(_ storageType: PreferenceStorageType) -> String {
        switch storageType {
        case .userDefaults: return "folder"
        case .keychain: return "lock"
        case .coreData: return "cylinder"
        }
    }

    private func storageTypeDescription(_ storageType: PreferenceStorageType) -> String {
        switch storageType {
        case .userDefaults:
            return "User preferences stored in plist files. Synchronous operations, suitable for simple key-value storage."
        case .keychain:
            return "Secure storage for sensitive data like passwords and tokens. Encrypted and protected by the system."
        case .coreData:
            return "Object graph and persistence framework. Suitable for complex data models and relationships."
        }
    }
}

struct PreferenceRowView: View {
    let preference: PreferenceItem
    let viewModel: PreferencesViewModel
    @State private var editableValue: String
    @State private var isEditing = false

    init(preference: PreferenceItem, viewModel: PreferencesViewModel) {
        self.preference = preference
        self.viewModel = viewModel
        self._editableValue = State(initialValue: preference.value)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Key and Type Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(preference.key)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(preference.type.displayName.lowercased())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                typeIndicator
            }

            // Value Editor
            valueEditor
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .listRowSeparator(.hidden)
    }

    private var typeIndicator: some View {
        Text(typeAbbreviation)
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(typeColor)
            .foregroundColor(.white)
            .cornerRadius(4)
    }

    private var typeAbbreviation: String {
        switch preference.type {
        case .string: return "STR"
        case .boolean: return "BOOL"
        case .number: return "NUM"
        case .data: return "DATA"
        }
    }

    private var typeColor: Color {
        switch preference.type {
        case .string: return .blue
        case .boolean: return .green
        case .number: return .orange
        case .data: return .red
        }
    }

    @ViewBuilder
    private var valueEditor: some View {
        switch preference.type {
        case .boolean:
            Toggle(isOn: Binding(
                get: { preference.value.lowercased() == "true" },
                set: { newValue in
                    viewModel.onEvent(.UpdatePreference(
                        key: preference.key,
                        value: newValue.description,
                        type: preference.type
                    ))
                }
            )) {
                Text("Value")
            }

        case .data:
            // Data preferences are read-only in this demo
            VStack(alignment: .leading, spacing: 4) {
                Text(preference.value)
                    .font(.body)
                    .foregroundColor(.secondary)

                Text("Read-only")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

        case .string, .number:
            if isEditing {
                editingView
            } else {
                displayView
            }
        }
    }

    private var editingView: some View {
        HStack {
            TextField("Enter value...", text: $editableValue)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Save") {
                viewModel.onEvent(.UpdatePreference(
                    key: preference.key,
                    value: editableValue,
                    type: preference.type
                ))
                isEditing = false
            }
            .foregroundColor(.blue)

            Button("Cancel") {
                editableValue = preference.value
                isEditing = false
            }
            .foregroundColor(.red)
        }
    }

    private var displayView: some View {
        HStack {
            Text(preference.value)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()

            Button("Edit") {
                isEditing = true
            }
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(.systemGray4))
            .foregroundColor(.primary)
            .cornerRadius(4)
        }
    }
}

struct AddPreferenceView: View {
    let viewModel: PreferencesViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var key = ""
    @State private var value = ""
    @State private var selectedType: PreferenceType = .string
    @State private var selectedStorageType: PreferenceStorageType = .userDefaults

    var body: some View {
        NavigationView {
            Form {
                Section("Preference Details") {
                    TextField("Key", text: $key)
                    TextField("Value", text: $value)

                    Picker("Type", selection: $selectedType) {
                        ForEach(PreferenceType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }

                    Picker("Storage Type", selection: $selectedStorageType) {
                        ForEach(PreferenceStorageType.allCases, id: \.self) { storageType in
                            Text(storageType.displayName).tag(storageType)
                        }
                    }
                }
            }
            .navigationTitle("Add Preference")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        // In a real app, this would add to the actual storage
                        // For demo purposes, we just dismiss
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(key.isEmpty || value.isEmpty)
                }
            }
        }
    }
}

#Preview {
    PreferencesScreen(viewModel: PreferencesViewModel())
}

//
//  PreferencesScreen.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import SwiftUI
import DesignSystem

struct PreferencesScreen: View {
    @ObservedObject var viewModel: PreferencesViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                content
            }
            .navigationTitle("Preferences")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.onEvent(.RefreshPreferences)
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
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
                    .refreshable {
                        viewModel.onEvent(.RefreshPreferences)
                    }
            }
        }
        .background(DSColor.Extra.background0)
    }

    private func searchSection(data: PreferencesUiData) -> some View {
        DSSearchField(
            text: Binding(
                get: { data.searchQuery },
                set: { viewModel.onEvent(.UpdateSearchQuery($0)) }
            ),
            placeholder: "Search requests...",
            backgroundColor: DSColor.Extra.white,
            onSearchSubmit: { _ in },
            onClear: { }
        )
        .padding(DSSpacing.s)
        .dsShadow(DSElevation.Shadow.medium)
    }

    private func storageTypeSection(data: PreferencesUiData) -> some View {
        let availableStorageTypes = DemoPreferenceStorageType.allCases.filter { storageType in
            data.preferences.contains { $0.storageType == storageType }
        }

        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.s) {
                ForEach(availableStorageTypes, id: \.self) { storageType in
                    storageTypeChip(storageType: storageType, data: data)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, DSSpacing.xs)
    }

    private func storageTypeChip(storageType: DemoPreferenceStorageType, data: PreferencesUiData) -> some View {
        let isSelected = data.selectedStorageType == storageType
        let count = data.preferences.filter { $0.storageType == storageType }.count

        return Button(action: {
            viewModel.onEvent(.SelectStorageType(storageType))
        }) {
            HStack(spacing: DSSpacing.xxs) {
                if isSelected {
                    DSIcons.Status.check
                        .font(.system(size: DSIconSize.s))
                        .foregroundColor(DSColor.Extra.white)
                }

                DSText(
                    "\(storageType.displayName) (\(count))",
                    style: .labelLarge,
                    color: isSelected ? DSColor.Extra.white : DSColor.Neutral.neutral100
                )
            }
            .padding(.horizontal, DSSpacing.s)
            .padding(.vertical, DSSpacing.xs)
            .background(isSelected ? DSColor.Primary.primary100 : .clear)
            .border(isSelected ? Color.blue : DSColor.Neutral.neutral40)
            .cornerRadius(DSRadius.xl)
            .dsBorder(DSColor.Neutral.neutral80, width: DSBorderWidth.regular, radius: DSRadius.xl)
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

            if data.selectedStorageType != nil || !data.searchQuery.isEmpty {
                Text("Try adjusting your search or selecting a different storage type")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Button("Reset Filters") {
                    viewModel.onEvent(.ClearSearch)
                    // Select first available storage type
                    let availableTypes = DemoPreferenceStorageType.allCases.filter { storageType in
                        data.preferences.contains { $0.storageType == storageType }
                    }
                    if let firstType = availableTypes.first {
                        viewModel.onEvent(.SelectStorageType(firstType))
                    }
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text("No preferences have been created yet")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func preferencesList(data: PreferencesUiData) -> some View {
        List {
            // Storage Type Description
            storageDescriptionSection(data: data)
                .listRowBackground(DSColor.Extra.background0)

            // Preferences
            ForEach(data.filteredPreferences) { preference in
                PreferenceRowView(preference: preference, viewModel: viewModel)
            }
            .listRowBackground(DSColor.Extra.background0)
            .listRowInsets(
                EdgeInsets(
                    top: DSSpacing.xs, leading: DSSpacing.m, bottom: DSSpacing.xs, trailing:  DSSpacing.m
                )
            )
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private func storageDescriptionSection(data: PreferencesUiData) -> some View {
        if let selectedStorageType = data.selectedStorageType {
            DSAlert(
                style: .info,
                title: selectedStorageType.displayName,
                message: storageTypeDescription(selectedStorageType)
            )
        }
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

            DSButton.primary("Try Again", size: .small) {
                viewModel.onEvent(.RefreshPreferences)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func storageTypeDescription(_ storageType: DemoPreferenceStorageType) -> String {
        switch storageType {
        case .userDefaults:
            return "User preferences stored in plist files. Synchronous operations, suitable for simple key-value storage."
        case .keychain:
            return "Secure storage for sensitive data like passwords and tokens. Encrypted and protected by the system."
        case .propertyList:
            return "Property list files (.plist) for storing hierarchical data structures in XML or binary format."
        }
    }
}

struct PreferenceRowView: View {
    let preference: DemoPreferenceItem
    let viewModel: PreferencesViewModel
    @State private var editableValue: String
    @State private var isEditing = false
    @State private var showFullValueSheet = false

    init(preference: DemoPreferenceItem, viewModel: PreferencesViewModel) {
        self.preference = preference
        self.viewModel = viewModel
        self._editableValue = State(initialValue: preference.value)
    }

    var body: some View {
        DSCard(style: .elevated) {
            VStack(alignment: .leading, spacing: 12) {
                // Key and Type Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        DSText(
                            preference.key,
                            style: .titleMedium
                        )

                        DSText(
                            preference.type.displayName.lowercased(),
                            style: .titleSmall,
                            color: DSColor.Neutral.neutral80
                        )
                    }

                    Spacer()

                    typeIndicator
                }

                valueEditor
            }
        }
        .listRowSeparator(.hidden)
    }

    private var typeIndicator: some View {
        DSText(
            typeAbbreviation,
            style: .bodyLarge,
            color: DSColor.Extra.white
        )
        .padding(.horizontal, DSSpacing.xs)
        .padding(.vertical, DSSpacing.xxs)
        .background(typeColor)
        .foregroundColor(DSColor.Extra.white)
        .dsCornerRadius(DSRadius.s)
    }

    private var typeAbbreviation: String {
        switch preference.type {
        case .string: return "STR"
        case .boolean: return "BOOL"
        case .integer: return "INT"
        case .float: return "FLT"
        case .data: return "DATA"
        case .array: return "ARR"
        case .dictionary: return "DICT"
        }
    }

    private var typeColor: Color {
        switch preference.type {
        case .string: return DSColor.Chart.blue
        case .boolean: return DSColor.Chart.green
        case .integer, .float: return DSColor.Chart.orange
        case .data: return DSColor.Chart.red
        case .array, .dictionary: return DSColor.Chart.purple
        }
    }

    @ViewBuilder
    private var valueEditor: some View {
        switch preference.type {
        case .boolean:
            DSToggle(
                isOn: Binding(
                    get: { preference.value.lowercased() == "true" },
                    set: { newValue in
                        viewModel.onEvent(.UpdatePreference(
                            key: preference.key,
                            value: newValue.description,
                            type: preference.type,
                            suite: preference.suite
                        ))
                    }
                ),
                label: "Value"
            )

        case .data, .array, .dictionary:
            // Complex types are read-only in this demo
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                DSText(
                    preference.value,
                    style: .bodyMedium,
                    color: DSColor.Neutral.neutral100,
                    lineLimit: 3,
                    truncationMode: .tail
                )
                
                HStack(alignment: .top, spacing: DSSpacing.xs) {
                    DSText(
                        "Read-only",
                        style: .labelMedium,
                        color: DSColor.Neutral.neutral80
                    )

                    Spacer()

                    Button(action: {
                        showFullValueSheet = true
                    }) {
                        DSIcons.Navigation.forward
                            .font(.system(size: DSIconSize.s))
                            .foregroundColor(DSColor.Primary.primary100)
                    }
                }
            }
            .sheet(isPresented: $showFullValueSheet) {
                CollectionValueDetailSheet(preference: preference)
            }

        case .string, .integer, .float:
            if isEditing {
                editingView
            } else {
                displayView
            }
        }
    }

    private var editingView: some View {
        HStack {
            DSTextField(
                text: $editableValue,
                placeholder: "Enter value..."
            )

            DSButton(
                "Save",
                style: .primary,
                size: .small,
                width: .fit
            ) {
                viewModel.onEvent(.UpdatePreference(
                    key: preference.key,
                    value: editableValue,
                    type: preference.type,
                    suite: preference.suite
                ))
                isEditing = false
            }

            DSButton(
                "Cancel",
                style: .ghost,
                size: .small,
                width: .fit,
                foregroundColor: DSColor.Error.error100
            ) {
                editableValue = preference.value
                isEditing = false
            }
        }
    }

    private var displayView: some View {
        HStack {
            DSText(
                preference.value,
                style: .bodyLarge,
                color: DSColor.Neutral.neutral100
            )

            Spacer()

            DSButton(
                "Edit",
                style: .neutral,
                size: .small,
                width: .fit
            ) {
                isEditing = true
            }
        }
    }
}

// MARK: - Collection Value Detail Sheet
struct CollectionValueDetailSheet: View {
    let preference: DemoPreferenceItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                // Key Section
                Section {
                    HStack {
                        DSText(
                            "Key",
                            style: .bodyMedium,
                            color: DSColor.Neutral.neutral100
                        )
                        Spacer()
                        DSText(
                            preference.key,
                            style: .bodyMedium,
                            color: DSColor.Neutral.neutral80
                        )
                    }
                }
                .listRowBackground(DSColor.Extra.white)

                // Metadata Section
                Section {
                    // Type Row
                    HStack {
                        DSText(
                            "Type",
                            style: .bodyMedium,
                            color: DSColor.Neutral.neutral100
                        )
                        Spacer()
                        DSText(
                            preference.type.displayName,
                            style: .bodyMedium,
                            color: typeColor
                        )
                        .padding(.horizontal, DSSpacing.xs)
                        .padding(.vertical, 2)
                        .background(typeColor.opacity(0.15))
                        .dsCornerRadius(DSRadius.s)
                    }

                    // Storage Row
                    HStack {
                        DSText(
                            "Storage",
                            style: .bodyMedium,
                            color: DSColor.Neutral.neutral100
                        )
                        Spacer()
                        DSText(
                            preference.storageType.displayName,
                            style: .bodyMedium,
                            color: DSColor.Neutral.neutral80
                        )
                    }

                    // Suite Row (if applicable)
                    if !preference.suite.isEmpty {
                        HStack {
                            DSText(
                                "Suite",
                                style: .bodyMedium,
                                color: DSColor.Neutral.neutral100
                            )
                            Spacer()
                            DSText(
                                preference.suite,
                                style: .bodyMedium,
                                color: DSColor.Neutral.neutral80
                            )
                        }
                    }
                }
                .listRowBackground(DSColor.Extra.white)

                // Value Section
                Section {
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        DSText(
                            "Value",
                            style: .labelMedium,
                            color: DSColor.Neutral.neutral80
                        )

                        ScrollView(.horizontal, showsIndicators: true) {
                            DSText(
                                preference.value,
                                style: .bodyMedium,
                                color: DSColor.Neutral.neutral100
                            )
                            .textSelection(.enabled)
                            .padding(.vertical, DSSpacing.xs)
                        }
                        .frame(maxHeight: 300)

                        DSText(
                            "Tap and hold to select and copy",
                            style: .labelSmall,
                            color: DSColor.Neutral.neutral60
                        )
                        .padding(.top, DSSpacing.xxs)
                    }
                    .padding(.vertical, DSSpacing.xs)
                } header: {
                    DSText(
                        "CONTENT",
                        style: .labelSmall,
                        color: DSColor.Neutral.neutral60
                    )
                }
                .listRowBackground(DSColor.Extra.white)
            }
            .listStyle(.insetGrouped)
            .background(DSColor.Extra.background0)
            .navigationTitle("Preference Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var typeColor: Color {
        switch preference.type {
        case .string: return DSColor.Chart.blue
        case .boolean: return DSColor.Chart.green
        case .integer, .float: return DSColor.Chart.orange
        case .data: return DSColor.Chart.red
        case .array, .dictionary: return DSColor.Chart.purple
        }
    }
}

#Preview {
    PreferencesScreen(viewModel: PreferencesViewModel())
}

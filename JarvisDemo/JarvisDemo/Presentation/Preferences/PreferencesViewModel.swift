//
//  PreferencesViewModel.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon on 2/10/25.
//  Manages demo app's own preferences (independent from Jarvis SDK)
//

import SwiftUI
import Combine

struct PreferencesUiData {
    let preferences: [DemoPreferenceItem]
    let filteredPreferences: [DemoPreferenceItem]
    let selectedStorageType: DemoPreferenceStorageType?
    let searchQuery: String
    let isRefreshing: Bool

    static let empty = PreferencesUiData(
        preferences: [],
        filteredPreferences: [],
        selectedStorageType: nil,
        searchQuery: "",
        isRefreshing: false
    )
}

@MainActor
class PreferencesViewModel: ObservableObject {
    @Published var uiState: ResourceState<PreferencesUiData> = .idle

    private let managePreferencesUseCase: ManageDemoPreferencesUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    init(managePreferencesUseCase: ManageDemoPreferencesUseCaseProtocol = ManageDemoPreferencesUseCase()) {
        self.managePreferencesUseCase = managePreferencesUseCase
        loadInitialData()
    }

    private func loadInitialData() {
        uiState = .loading

        // Generate sample data on first load
        managePreferencesUseCase.generateSampleData()

        // Subscribe to preferences updates
        managePreferencesUseCase.getAllPreferences()
            .sink { [weak self] preferences in
                guard let self = self else { return }
                self.handlePreferencesLoaded(preferences)
            }
            .store(in: &cancellables)
    }

    private func handlePreferencesLoaded(_ preferences: [DemoPreferenceItem]) {
        // Preserve current selection if it exists, otherwise auto-select first available
        let currentSelectedType: DemoPreferenceStorageType?
        if case .success(let currentData) = uiState {
            currentSelectedType = currentData.selectedStorageType
        } else {
            currentSelectedType = nil
        }

        let availableStorageTypes = DemoPreferenceStorageType.allCases.filter { storageType in
            preferences.contains { $0.storageType == storageType }
        }

        // Use current selection if still valid, otherwise select first available
        let selectedType: DemoPreferenceStorageType?
        if let current = currentSelectedType, availableStorageTypes.contains(current) {
            selectedType = current
        } else {
            selectedType = availableStorageTypes.first
        }

        let currentSearchQuery: String
        if case .success(let currentData) = uiState {
            currentSearchQuery = currentData.searchQuery
        } else {
            currentSearchQuery = ""
        }

        let filteredPreferences = managePreferencesUseCase.filteredPreferences(
            allPreferences: preferences,
            storageType: selectedType,
            searchQuery: currentSearchQuery
        )
        
        let uiData = PreferencesUiData(
            preferences: preferences,
            filteredPreferences: filteredPreferences,
            selectedStorageType: selectedType,
            searchQuery: currentSearchQuery,
            isRefreshing: false
        )

        uiState = .success(uiData)
    }

    private enum UpdateValue<T> {
        case keep
        case update(T)
    }

    private func updateUiData(
        preferences: [DemoPreferenceItem]? = nil,
        selectedStorageType: UpdateValue<DemoPreferenceStorageType?> = .keep,
        searchQuery: String? = nil,
        isRefreshing: Bool? = nil
    ) {
        guard case .success(let currentData) = uiState else { return }

        let updatedPreferences = preferences ?? currentData.preferences

        let updatedStorageType: DemoPreferenceStorageType?
        switch selectedStorageType {
        case .keep:
            updatedStorageType = currentData.selectedStorageType
        case .update(let newType):
            updatedStorageType = newType
        }

        let updatedSearchQuery = searchQuery ?? currentData.searchQuery
        let updatedIsRefreshing = isRefreshing ?? currentData.isRefreshing

        let filteredPreferences = managePreferencesUseCase.filteredPreferences(
            allPreferences: updatedPreferences,
            storageType: updatedStorageType,
            searchQuery: updatedSearchQuery
        )

        let uiData = PreferencesUiData(
            preferences: updatedPreferences,
            filteredPreferences: filteredPreferences,
            selectedStorageType: updatedStorageType,
            searchQuery: updatedSearchQuery,
            isRefreshing: updatedIsRefreshing
        )

        uiState = .success(uiData)
    }

    // MARK: - Events

    func onEvent(_ event: PreferencesEvent) {
        switch event {
        case .SelectStorageType(let storageType):
            selectStorageType(storageType)
        case .UpdateSearchQuery(let query):
            updateSearchQuery(query)
        case .UpdatePreference(let key, let value, let type, let suite):
            updatePreference(key: key, value: value, type: type, suite: suite)
        case .RefreshPreferences:
            refreshPreferences()
        case .ClearSearch:
            clearSearch()
        case .GenerateSampleData:
            generateSampleData()
        }
    }

    private func selectStorageType(_ storageType: DemoPreferenceStorageType?) {
        updateUiData(selectedStorageType: .update(storageType))
    }

    private func updateSearchQuery(_ query: String) {
        updateUiData(searchQuery: query)
    }

    private func updatePreference(key: String, value: String, type: DemoPreferenceType, suite: String) {
        guard case .success(let currentData) = uiState else { return }

        // Find the existing preference to get its storage type
        guard let existingPreference = currentData.preferences.first(where: { $0.key == key }) else {
            return
        }

        // Update through use case
        managePreferencesUseCase.updatePreference(
            key: key,
            value: value,
            type: type,
            storageType: existingPreference.storageType,
            suite: suite
        )

        // The publisher will automatically update the UI
    }

    private func refreshPreferences() {
        // The publisher already handles continuous updates
        updateUiData(isRefreshing: false)
    }

    private func clearSearch() {
        updateUiData(searchQuery: "")
    }

    private func generateSampleData() {
        managePreferencesUseCase.generateSampleData()
        // The publisher will automatically update the UI
    }
}

enum PreferencesEvent {
    case SelectStorageType(DemoPreferenceStorageType?)
    case UpdateSearchQuery(String)
    case UpdatePreference(key: String, value: String, type: DemoPreferenceType, suite: String)
    case RefreshPreferences
    case ClearSearch
    case GenerateSampleData
}

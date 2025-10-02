//
//  PreferencesViewModel.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon on 2/10/25.
//

import SwiftUI
import Combine

struct PreferencesUiData {
    let preferences: [PreferenceItem]
    let filteredPreferences: [PreferenceItem]
    let selectedStorageType: PreferenceStorageType
    let searchQuery: String
    let isRefreshing: Bool

    static let empty = PreferencesUiData(
        preferences: [],
        filteredPreferences: [],
        selectedStorageType: .userDefaults,
        searchQuery: "",
        isRefreshing: false
    )
}

@MainActor
class PreferencesViewModel: ObservableObject {
    @Published var uiState: ResourceState<PreferencesUiData> = .idle

    private let managePreferencesUseCase: ManagePreferencesUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    init(managePreferencesUseCase: ManagePreferencesUseCaseProtocol = ManagePreferencesUseCase()) {
        self.managePreferencesUseCase = managePreferencesUseCase
        loadInitialData()
    }

    private func loadInitialData() {
        uiState = .loading

        let preferences = managePreferencesUseCase.getAllPreferences()
        let filteredPreferences = managePreferencesUseCase.filteredPreferences(
            allPreferences: preferences,
            storageType: .userDefaults,
            searchQuery: ""
        )

        let uiData = PreferencesUiData(
            preferences: preferences,
            filteredPreferences: filteredPreferences,
            selectedStorageType: .userDefaults,
            searchQuery: "",
            isRefreshing: false
        )

        uiState = .success(uiData)
    }

    private func updateUiData(
        preferences: [PreferenceItem]? = nil,
        selectedStorageType: PreferenceStorageType? = nil,
        searchQuery: String? = nil,
        isRefreshing: Bool? = nil
    ) {
        guard case .success(let currentData) = uiState else { return }

        let updatedPreferences = preferences ?? currentData.preferences
        let updatedStorageType = selectedStorageType ?? currentData.selectedStorageType
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
        case .UpdatePreference(let key, let value, let type):
            updatePreference(key: key, value: value, type: type)
        case .RefreshPreferences:
            refreshPreferences()
        case .ClearSearch:
            clearSearch()
        }
    }

    private func selectStorageType(_ storageType: PreferenceStorageType) {
        updateUiData(selectedStorageType: storageType)
    }

    private func updateSearchQuery(_ query: String) {
        updateUiData(searchQuery: query)
    }

    private func updatePreference(key: String, value: String, type: PreferenceType) {
        guard case .success(let currentData) = uiState else { return }

        var updatedPreferences = currentData.preferences
        if let index = updatedPreferences.firstIndex(where: { $0.key == key }) {
            let existingPreference = updatedPreferences[index]
            updatedPreferences[index] = PreferenceItem(
                key: key,
                value: value,
                type: type,
                storageType: existingPreference.storageType
            )
        }

        updateUiData(preferences: updatedPreferences)
    }

    private func refreshPreferences() {
        updateUiData(isRefreshing: true)

        // Simulate refresh with a small delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let preferences = self?.managePreferencesUseCase.getAllPreferences() ?? []
            self?.updateUiData(preferences: preferences, isRefreshing: false)
        }
    }

    private func clearSearch() {
        updateUiData(searchQuery: "")
    }
}

enum PreferencesEvent {
    case SelectStorageType(PreferenceStorageType)
    case UpdateSearchQuery(String)
    case UpdatePreference(key: String, value: String, type: PreferenceType)
    case RefreshPreferences
    case ClearSearch
}

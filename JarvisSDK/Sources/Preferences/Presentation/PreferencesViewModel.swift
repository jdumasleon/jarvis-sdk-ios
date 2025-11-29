import Foundation
import Combine
#if canImport(Presentation)
import JarvisPresentation
#endif
import JarvisDomain
import JarvisPreferencesDomain
import JarvisPreferencesData
import JarvisCommon

/// View model for preferences inspector
@MainActor
public class PreferencesViewModel: BaseViewModel {
    @Published public var uiState = PreferencesUIState()

    @Injected private var getPreferencesUseCase: GetPreferencesUseCase
    @Injected private var updatePreferenceUseCase: UpdatePreferenceUseCase
    @Injected private var deletePreferenceUseCase: DeletePreferenceUseCase

    private let itemsPerPage = 20
    private var currentPage = 0
    private var allFilteredPreferences: [Preference] = []

    public override init() {
        super.init()
    }

    public func loadPreferences() {
        Task {
            // Set loading state
            isLoading = true
            clearError()

            do {
                let preferences = try await getPreferencesUseCase.execute(uiState.filter == .all ? nil : uiState.filter)
                let filtered = filterAndSearch(preferences, searchQuery: uiState.searchQuery, selectedType: uiState.selectedType)

                // Reset pagination
                currentPage = 0
                allFilteredPreferences = filtered
                let initialItems = Array(filtered.prefix(itemsPerPage))
                let hasMore = filtered.count > itemsPerPage

                // Update UI state and clear loading
                isLoading = false
                uiState = PreferencesUIState(
                    preferences: preferences,
                    filteredPreferences: initialItems,
                    selectedPreference: uiState.selectedPreference,
                    filter: uiState.filter,
                    searchQuery: uiState.searchQuery,
                    selectedType: uiState.selectedType,
                    isLoading: false,
                    error: nil,
                    hasMorePages: hasMore,
                    isLoadingMore: false
                )
            } catch {
                // Clear loading and set error
                isLoading = false
                handleError(error)
                uiState = PreferencesUIState(
                    preferences: uiState.preferences,
                    filteredPreferences: uiState.filteredPreferences,
                    selectedPreference: uiState.selectedPreference,
                    filter: uiState.filter,
                    searchQuery: uiState.searchQuery,
                    selectedType: uiState.selectedType,
                    isLoading: false,
                    error: error,
                    hasMorePages: false,
                    isLoadingMore: false
                )
            }
        }
    }

    public func loadMorePreferences() {
        guard uiState.hasMorePages && !uiState.isLoadingMore else { return }

        Task {
            uiState = PreferencesUIState(
                preferences: uiState.preferences,
                filteredPreferences: uiState.filteredPreferences,
                selectedPreference: uiState.selectedPreference,
                filter: uiState.filter,
                searchQuery: uiState.searchQuery,
                selectedType: uiState.selectedType,
                isLoading: uiState.isLoading,
                error: uiState.error,
                hasMorePages: uiState.hasMorePages,
                isLoadingMore: true
            )

            currentPage += 1
            let startIndex = currentPage * itemsPerPage
            let endIndex = min(startIndex + itemsPerPage, allFilteredPreferences.count)

            if startIndex < allFilteredPreferences.count {
                let newItems = Array(allFilteredPreferences[startIndex..<endIndex])
                let allItems = uiState.filteredPreferences + newItems
                let hasMore = endIndex < allFilteredPreferences.count

                uiState = PreferencesUIState(
                    preferences: uiState.preferences,
                    filteredPreferences: allItems,
                    selectedPreference: uiState.selectedPreference,
                    filter: uiState.filter,
                    searchQuery: uiState.searchQuery,
                    selectedType: uiState.selectedType,
                    isLoading: false,
                    error: nil,
                    hasMorePages: hasMore,
                    isLoadingMore: false
                )
            }
        }
    }

    public func applyFilter(_ filter: PreferenceFilter) {
        // Update filter first, then reload preferences from the source
        uiState = PreferencesUIState(
            preferences: uiState.preferences,
            filteredPreferences: uiState.filteredPreferences,
            selectedPreference: uiState.selectedPreference,
            filter: filter,
            searchQuery: uiState.searchQuery,
            selectedType: uiState.selectedType,
            isLoading: false,
            error: nil,
            hasMorePages: false,
            isLoadingMore: false
        )
        loadPreferences()
    }

    public func search(_ query: String) {
        let filtered = filterAndSearch(uiState.preferences, searchQuery: query, selectedType: uiState.selectedType)
        allFilteredPreferences = filtered
        currentPage = 0
        let initialItems = Array(filtered.prefix(itemsPerPage))
        let hasMore = filtered.count > itemsPerPage

        uiState = PreferencesUIState(
            preferences: uiState.preferences,
            filteredPreferences: initialItems,
            selectedPreference: uiState.selectedPreference,
            filter: uiState.filter,
            searchQuery: query,
            selectedType: uiState.selectedType,
            isLoading: false,
            error: nil,
            hasMorePages: hasMore,
            isLoadingMore: false
        )
    }

    public func selectPreference(_ preference: Preference) {
        uiState = PreferencesUIState(
            preferences: uiState.preferences,
            filteredPreferences: uiState.filteredPreferences,
            selectedPreference: preference,
            filter: uiState.filter,
            searchQuery: uiState.searchQuery,
            selectedType: uiState.selectedType,
            isLoading: uiState.isLoading,
            error: uiState.error,
            hasMorePages: uiState.hasMorePages,
            isLoadingMore: uiState.isLoadingMore
        )
    }

    public func updatePreference(key: String, value: Any, source: PreferenceSource, suiteName: String?) {
        Task {
            do {
                let input = UpdatePreferenceUseCase.Input(
                    key: key,
                    value: value,
                    source: source,
                    suiteName: suiteName
                )
                let success = try await updatePreferenceUseCase.execute(input)
                if success {
                    loadPreferences()
                }
            } catch {
                handleError(error)
            }
        }
    }

    public func deletePreference(key: String, source: PreferenceSource, suiteName: String?) {
        Task {
            do {
                let input = DeletePreferenceUseCase.Input(
                    key: key,
                    source: source,
                    suiteName: suiteName
                )
                _ = try await deletePreferenceUseCase.execute(input)
                // Always reload to reflect the current state
                loadPreferences()
            } catch {
                handleError(error)
            }
        }
    }


    public func clearAllPreferences(source: PreferenceFilter) {
        Task {
            do {
                let preferencesToDelete = uiState.preferences.filter { preference in
                    switch source {
                    case .all:
                        return true
                    case .userDefaults:
                        return preference.source == .userDefaults
                    case .keychain:
                        return preference.source == .keychain
                    case .propertyList:
                        return preference.source == .propertyList
                    }
                }

                // Delete each preference
                for preference in preferencesToDelete {
                    let input = DeletePreferenceUseCase.Input(
                        key: preference.key,
                        source: preference.source,
                        suiteName: preference.suiteName
                    )
                    _ = try await deletePreferenceUseCase.execute(input)
                }

                // Reload preferences
                loadPreferences()
            } catch {
                handleError(error)
            }
        }
    }

    public func filterByType(_ type: String?) {
        let filtered = filterAndSearch(uiState.preferences, searchQuery: uiState.searchQuery, selectedType: type)
        allFilteredPreferences = filtered
        currentPage = 0
        let initialItems = Array(filtered.prefix(itemsPerPage))
        let hasMore = filtered.count > itemsPerPage

        uiState = PreferencesUIState(
            preferences: uiState.preferences,
            filteredPreferences: initialItems,
            selectedPreference: uiState.selectedPreference,
            filter: uiState.filter,
            searchQuery: uiState.searchQuery,
            selectedType: type,
            isLoading: false,
            error: nil,
            hasMorePages: hasMore,
            isLoadingMore: false
        )
    }

    private func filterAndSearch(_ preferences: [Preference], searchQuery: String, selectedType: String?) -> [Preference] {
        var filtered = preferences

        // Apply type filter
        if let type = selectedType {
            filtered = filtered.filter { preference in
                preference.type.lowercased().contains(type.lowercased())
            }
        }

        // Apply search query
        if !searchQuery.isEmpty {
            filtered = filtered.filter { preference in
                preference.key.localizedCaseInsensitiveContains(searchQuery) ||
                String(describing: preference.value).localizedCaseInsensitiveContains(searchQuery)
            }
        }

        return filtered
    }
}

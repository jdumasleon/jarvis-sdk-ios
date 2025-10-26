import Foundation
import Combine
import Presentation
import Domain
import JarvisPreferencesDomain
import JarvisPreferencesData

/// View model for preferences inspector
@MainActor
public class PreferencesViewModel: BaseViewModel {
    @Published public var uiState = PreferencesUIState()

    private let getPreferencesUseCase: GetPreferencesUseCase
    private let updatePreferenceUseCase: UpdatePreferenceUseCase
    private let deletePreferenceUseCase: DeletePreferenceUseCase

    public init(
        getPreferencesUseCase: GetPreferencesUseCase? = nil,
        updatePreferenceUseCase: UpdatePreferenceUseCase? = nil,
        deletePreferenceUseCase: DeletePreferenceUseCase? = nil
    ) {
        let repository = PreferenceRepository()
        self.getPreferencesUseCase = getPreferencesUseCase ?? GetPreferencesUseCase(repository: repository)
        self.updatePreferenceUseCase = updatePreferenceUseCase ?? UpdatePreferenceUseCase(repository: repository)
        self.deletePreferenceUseCase = deletePreferenceUseCase ?? DeletePreferenceUseCase(repository: repository)
        super.init()
    }

    public func loadPreferences() {
        Task {
            isLoading = true
            clearError()

            do {
                let preferences = try await getPreferencesUseCase.execute(uiState.filter == .all ? nil : uiState.filter)

                uiState = PreferencesUIState(
                    preferences: preferences,
                    filteredPreferences: filterAndSearch(preferences),
                    selectedPreference: uiState.selectedPreference,
                    filter: uiState.filter,
                    searchQuery: uiState.searchQuery,
                    isLoading: false,
                    error: nil
                )
            } catch {
                handleError(error)
                uiState = PreferencesUIState(
                    preferences: uiState.preferences,
                    filteredPreferences: uiState.filteredPreferences,
                    selectedPreference: uiState.selectedPreference,
                    filter: uiState.filter,
                    searchQuery: uiState.searchQuery,
                    isLoading: false,
                    error: error
                )
            }
        }
    }

    public func applyFilter(_ filter: PreferenceFilter) {
        uiState = PreferencesUIState(
            preferences: uiState.preferences,
            filteredPreferences: filterAndSearch(uiState.preferences),
            selectedPreference: uiState.selectedPreference,
            filter: filter,
            searchQuery: uiState.searchQuery,
            isLoading: false,
            error: nil
        )
        loadPreferences()
    }

    public func search(_ query: String) {
        uiState = PreferencesUIState(
            preferences: uiState.preferences,
            filteredPreferences: filterAndSearch(uiState.preferences),
            selectedPreference: uiState.selectedPreference,
            filter: uiState.filter,
            searchQuery: query,
            isLoading: false,
            error: nil
        )
    }

    public func selectPreference(_ preference: Preference) {
        uiState = PreferencesUIState(
            preferences: uiState.preferences,
            filteredPreferences: uiState.filteredPreferences,
            selectedPreference: preference,
            filter: uiState.filter,
            searchQuery: uiState.searchQuery,
            isLoading: uiState.isLoading,
            error: uiState.error
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
                let success = try await deletePreferenceUseCase.execute(input)
                if success {
                    loadPreferences()
                }
            } catch {
                handleError(error)
            }
        }
    }

    private func filterAndSearch(_ preferences: [Preference]) -> [Preference] {
        var filtered = preferences

        // Apply search query
        if !uiState.searchQuery.isEmpty {
            filtered = filtered.filter { preference in
                preference.key.localizedCaseInsensitiveContains(uiState.searchQuery) ||
                String(describing: preference.value).localizedCaseInsensitiveContains(uiState.searchQuery)
            }
        }

        return filtered
    }
}

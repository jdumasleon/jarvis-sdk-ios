import Foundation
import Domain
import JarvisPreferencesDomain

/// UI state for preferences inspector
public struct PreferencesUIState {
    public let preferences: [Preference]
    public let filteredPreferences: [Preference]
    public let selectedPreference: Preference?
    public let filter: PreferenceFilter
    public let searchQuery: String
    public let isLoading: Bool
    public let error: Error?

    public init(
        preferences: [Preference] = [],
        filteredPreferences: [Preference] = [],
        selectedPreference: Preference? = nil,
        filter: PreferenceFilter = .all,
        searchQuery: String = "",
        isLoading: Bool = false,
        error: Error? = nil
    ) {
        self.preferences = preferences
        self.filteredPreferences = filteredPreferences
        self.selectedPreference = selectedPreference
        self.filter = filter
        self.searchQuery = searchQuery
        self.isLoading = isLoading
        self.error = error
    }
}

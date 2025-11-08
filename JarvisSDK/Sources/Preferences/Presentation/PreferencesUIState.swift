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
    public let selectedType: String?
    public let isLoading: Bool
    public let error: Error?

    // Infinite scroll state
    public let hasMorePages: Bool
    public let isLoadingMore: Bool

    public init(
        preferences: [Preference] = [],
        filteredPreferences: [Preference] = [],
        selectedPreference: Preference? = nil,
        filter: PreferenceFilter = .all,
        searchQuery: String = "",
        selectedType: String? = nil,
        isLoading: Bool = false,
        error: Error? = nil,
        hasMorePages: Bool = false,
        isLoadingMore: Bool = false
    ) {
        self.preferences = preferences
        self.filteredPreferences = filteredPreferences
        self.selectedPreference = selectedPreference
        self.filter = filter
        self.searchQuery = searchQuery
        self.selectedType = selectedType
        self.isLoading = isLoading
        self.error = error
        self.hasMorePages = hasMorePages
        self.isLoadingMore = isLoadingMore
    }
}

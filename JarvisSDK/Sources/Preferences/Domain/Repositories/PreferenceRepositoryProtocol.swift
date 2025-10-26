//
//  PreferenceRepositoryProtocol.swift
//  JarvisSDK
//
//  Repository protocol for host app preferences
//

import Foundation

/// Protocol for managing host app preferences
public protocol PreferenceRepositoryProtocol {
    /// Scan all preferences from host app
    func scanAllPreferences() -> [Preference]

    /// Get preferences filtered by source
    func getPreferences(by source: PreferenceSource) -> [Preference]

    /// Get preferences from a specific suite/service
    func getPreferences(from suiteName: String) -> [Preference]

    /// Update a preference value
    func updatePreference(key: String, value: Any, source: PreferenceSource, suiteName: String?) -> Bool

    /// Delete a preference
    func deletePreference(key: String, source: PreferenceSource, suiteName: String?) -> Bool

    /// Refresh preferences (rescan)
    func refresh() -> [Preference]
}

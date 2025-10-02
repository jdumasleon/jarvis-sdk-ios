//
//  ManagePreferencesUseCase.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon on 2/10/25.
//

import Foundation

protocol ManagePreferencesUseCaseProtocol {
    func getAllPreferences() -> [PreferenceItem]
    func updatePreference(key: String, value: String, type: PreferenceType) -> PreferenceItem?
    func filteredPreferences(
        allPreferences: [PreferenceItem],
        storageType: PreferenceStorageType,
        searchQuery: String
    ) -> [PreferenceItem]
}

final class ManagePreferencesUseCase: ManagePreferencesUseCaseProtocol {

    func getAllPreferences() -> [PreferenceItem] {
        return PreferenceItem.mockPreferences
    }

    func updatePreference(key: String, value: String, type: PreferenceType) -> PreferenceItem? {
        // In a real implementation, this would update the actual storage
        // For demo purposes, we return a new preference item
        return PreferenceItem(
            key: key,
            value: value,
            type: type,
            storageType: .userDefaults // Would be determined based on actual storage
        )
    }

    func filteredPreferences(
        allPreferences: [PreferenceItem],
        storageType: PreferenceStorageType,
        searchQuery: String
    ) -> [PreferenceItem] {
        let storageFiltered = allPreferences.filter { $0.storageType == storageType }

        if searchQuery.isEmpty {
            return storageFiltered
        } else {
            return storageFiltered.filter {
                $0.key.localizedCaseInsensitiveContains(searchQuery) ||
                $0.value.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }
}

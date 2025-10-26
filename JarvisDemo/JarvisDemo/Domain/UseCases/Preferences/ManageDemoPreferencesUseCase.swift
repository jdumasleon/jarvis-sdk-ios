//
//  ManageDemoPreferencesUseCase.swift
//  JarvisDemo
//
//  UseCase for managing demo app's own preferences
//

import Foundation
import Combine

protocol ManageDemoPreferencesUseCaseProtocol {
    func getAllPreferences() -> AnyPublisher<[DemoPreferenceItem], Never>
    func getPreferencesByType(_ type: DemoPreferenceStorageType) -> [DemoPreferenceItem]
    func addPreference(key: String, value: String, type: DemoPreferenceType, storageType: DemoPreferenceStorageType, suite: String)
    func updatePreference(key: String, value: String, type: DemoPreferenceType, storageType: DemoPreferenceStorageType, suite: String)
    func deletePreference(key: String, storageType: DemoPreferenceStorageType)
    func generateSampleData()
    func filteredPreferences(
        allPreferences: [DemoPreferenceItem],
        storageType: DemoPreferenceStorageType?,
        searchQuery: String
    ) -> [DemoPreferenceItem]
}

final class ManageDemoPreferencesUseCase: ManageDemoPreferencesUseCaseProtocol {

    // MARK: - Properties

    private let repository: DemoPreferencesRepository

    // MARK: - Initialization

    init(repository: DemoPreferencesRepository = DemoPreferencesRepository()) {
        self.repository = repository
    }

    // MARK: - UseCase Methods

    func getAllPreferences() -> AnyPublisher<[DemoPreferenceItem], Never> {
        return repository.getAllPreferencesPublisher()
    }

    func getPreferencesByType(_ type: DemoPreferenceStorageType) -> [DemoPreferenceItem] {
        return repository.getPreferences(by: type)
    }

    func addPreference(key: String, value: String, type: DemoPreferenceType, storageType: DemoPreferenceStorageType, suite: String) {
        repository.setPreference(key: key, value: value, type: type, storageType: storageType, suite: suite)
    }

    func updatePreference(key: String, value: String, type: DemoPreferenceType, storageType: DemoPreferenceStorageType, suite: String) {
        repository.setPreference(key: key, value: value, type: type, storageType: storageType, suite: suite)
    }

    func deletePreference(key: String, storageType: DemoPreferenceStorageType) {
        repository.deletePreference(key: key, storageType: storageType)
    }

    func generateSampleData() {
        repository.generateSampleData()
    }

    func filteredPreferences(
        allPreferences: [DemoPreferenceItem],
        storageType: DemoPreferenceStorageType?,
        searchQuery: String
    ) -> [DemoPreferenceItem] {
        // Filter by storage type if specified
        var filtered = allPreferences
        if let storageType = storageType {
            filtered = filtered.filter { $0.storageType == storageType }
        }

        // Filter by search query
        if !searchQuery.isEmpty {
            filtered = filtered.filter {
                $0.key.localizedCaseInsensitiveContains(searchQuery) ||
                $0.value.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        return filtered
    }
}

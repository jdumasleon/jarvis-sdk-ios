//
//  GetPreferencesUseCase.swift
//  JarvisSDK
//
//  Use case for getting host app preferences
//

import Foundation
import JarvisCommon
import JarvisDomain

/// Get all host app preferences
public struct GetPreferencesUseCase: UseCase {
    public typealias Input = PreferenceFilter?
    public typealias Output = [Preference]

    private let repository: PreferenceRepositoryProtocol

    public init(repository: PreferenceRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ input: PreferenceFilter?) async throws -> [Preference] {
        // Run the synchronous scanning on a background thread to avoid blocking main thread
        return await Task.detached(priority: .userInitiated) {
            let allPreferences = repository.scanAllPreferences()

            guard let filter = input else {
                return allPreferences
            }

            switch filter {
            case .all:
                return allPreferences
            case .userDefaults:
                return allPreferences.filter { $0.source == .userDefaults }
            case .keychain:
                return allPreferences.filter { $0.source == .keychain }
            case .propertyList:
                return allPreferences.filter { $0.source == .propertyList }
            }
        }.value
    }
}

/// Filter for preferences
public enum PreferenceFilter: String, CaseIterable {
    case all = "All"
    case userDefaults = "UserDefaults"
    case keychain = "Keychain"
    case propertyList = "PropertyList"

    public var displayName: String {
        rawValue
    }

    public var source: PreferenceSource? {
        switch self {
        case .all:
            return nil
        case .userDefaults:
            return .userDefaults
        case .keychain:
            return .keychain
        case .propertyList:
            return .propertyList
        }
    }
}

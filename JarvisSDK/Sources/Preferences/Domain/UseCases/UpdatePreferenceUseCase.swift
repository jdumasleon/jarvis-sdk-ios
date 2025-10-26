//
//  UpdatePreferenceUseCase.swift
//  JarvisSDK
//
//  Use case for updating host app preference
//

import Foundation
import Common
import Domain

/// Update a host app preference
public struct UpdatePreferenceUseCase: UseCase {
    public struct Input {
        public let key: String
        public let value: Any
        public let source: PreferenceSource
        public let suiteName: String?

        public init(key: String, value: Any, source: PreferenceSource, suiteName: String?) {
            self.key = key
            self.value = value
            self.source = source
            self.suiteName = suiteName
        }
    }

    public typealias Output = Bool

    private let repository: PreferenceRepositoryProtocol

    public init(repository: PreferenceRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ input: Input) async throws -> Bool {
        return repository.updatePreference(
            key: input.key,
            value: input.value,
            source: input.source,
            suiteName: input.suiteName
        )
    }
}

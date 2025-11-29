//
//  DeletePreferenceUseCase.swift
//  JarvisSDK
//
//  Use case for deleting host app preference
//

import Foundation
import JarvisCommon
import JarvisDomain

/// Delete a host app preference
public struct DeletePreferenceUseCase: UseCase {
    public struct Input {
        public let key: String
        public let source: PreferenceSource
        public let suiteName: String?

        public init(key: String, source: PreferenceSource, suiteName: String?) {
            self.key = key
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
        return repository.deletePreference(
            key: input.key,
            source: input.source,
            suiteName: input.suiteName
        )
    }
}

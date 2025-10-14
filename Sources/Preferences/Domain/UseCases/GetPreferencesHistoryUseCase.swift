import Foundation
import Common
import Domain

/// Get preferences history use case
public struct GetPreferencesHistoryUseCase: UseCase {
    public typealias Input = String // Preference key
    public typealias Output = [PreferenceChange]

    private let repository: PreferenceChangeRepositoryProtocol

    public init(repository: PreferenceChangeRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ input: String) async throws -> [PreferenceChange] {
        return try await repository.fetchByKey(input)
    }
}
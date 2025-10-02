import Foundation
import Common
import Domain

/// Monitor preferences changes use case
public struct MonitorPreferencesUseCase: UseCase {
    public typealias Input = Void
    public typealias Output = [PreferenceChange]

    private let repository: PreferenceChangeRepositoryProtocol

    public init(repository: PreferenceChangeRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ input: Void) async throws -> [PreferenceChange] {
        return try await repository.fetchAll()
    }
}
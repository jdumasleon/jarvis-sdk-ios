import Foundation
import Common
import Domain

/// Get network transaction details use case
public struct GetNetworkTransactionUseCase: UseCase {
    public typealias Input = String // Transaction ID
    public typealias Output = NetworkTransaction?

    private let repository: NetworkTransactionRepositoryProtocol

    public init(repository: NetworkTransactionRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ input: String) async throws -> NetworkTransaction? {
        return try await repository.fetch(id: input)
    }
}
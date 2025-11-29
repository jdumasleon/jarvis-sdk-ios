import Foundation
import JarvisCommon
import JarvisDomain

/// Monitor network transactions use case
public struct MonitorNetworkTransactionsUseCase: UseCase {
    public typealias Input = Void
    public typealias Output = [NetworkTransaction]

    private let repository: NetworkTransactionRepositoryProtocol

    public init(repository: NetworkTransactionRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ input: Void) async throws -> [NetworkTransaction] {
        return try await repository.fetchAll()
    }
}

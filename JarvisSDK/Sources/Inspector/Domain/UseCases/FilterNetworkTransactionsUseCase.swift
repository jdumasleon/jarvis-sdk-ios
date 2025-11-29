import Foundation
import JarvisCommon
import JarvisDomain

/// Filter network transactions use case
public struct FilterNetworkTransactionsUseCase: UseCase {
    public typealias Input = TransactionFilter
    public typealias Output = [NetworkTransaction]

    private let repository: NetworkTransactionRepositoryProtocol

    public init(repository: NetworkTransactionRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ input: TransactionFilter) async throws -> [NetworkTransaction] {
        return try await repository.fetchFiltered(by: input)
    }
}

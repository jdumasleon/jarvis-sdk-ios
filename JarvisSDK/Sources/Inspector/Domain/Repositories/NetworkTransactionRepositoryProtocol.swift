import Foundation
import Common
import Domain

/// Protocol for network transaction repository
public protocol NetworkTransactionRepositoryProtocol {
    func save(_ transaction: NetworkTransaction) async throws
    func fetch(id: String) async throws -> NetworkTransaction?
    func fetchAll() async throws -> [NetworkTransaction]
    func delete(id: String) async throws
    func deleteAll() async throws
    func fetchRecent(limit: Int) async throws -> [NetworkTransaction]
    func fetchByMethod(_ method: String) async throws -> [NetworkTransaction]
    func fetchByStatusCode(_ statusCode: Int) async throws -> [NetworkTransaction]
    func fetchFiltered(by filter: TransactionFilter) async throws -> [NetworkTransaction]
    func deleteOldTransactions(beforeTimestamp: TimeInterval) async throws
}
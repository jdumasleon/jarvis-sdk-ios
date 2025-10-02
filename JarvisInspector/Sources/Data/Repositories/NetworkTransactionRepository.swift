import Foundation
import Common
import Data
import Domain
import JarvisInspectorDomain

/// Repository for network transaction data
public class NetworkTransactionRepository: NetworkTransactionRepositoryProtocol {

    private var transactions: [NetworkTransactionData] = []

    public init() {
        // In-memory storage for now
    }

    public func save(_ transaction: NetworkTransaction) async throws {
        let data = NetworkTransactionData(
            id: transaction.id,
            requestId: UUID().uuidString,
            responseId: transaction.response != nil ? UUID().uuidString : nil,
            method: transaction.request.method.rawValue,
            url: transaction.request.url,
            requestHeaders: transaction.request.headers,
            requestBody: transaction.request.body,
            responseHeaders: transaction.response?.headers,
            responseBody: transaction.response?.body,
            statusCode: transaction.response?.statusCode,
            startTime: transaction.startTime,
            endTime: transaction.endTime,
            status: transaction.status.rawValue
        )

        transactions.append(data)
    }

    public func fetch(id: String) async throws -> NetworkTransaction? {
        if let data = transactions.first(where: { $0.id == id }) {
            return convertToEntity(data)
        }

        // Check if available in memory (simplified for now)

        return nil
    }

    public func fetchAll() async throws -> [NetworkTransaction] {
        return transactions.compactMap(convertToEntity)
    }

    public func delete(id: String) async throws {
        transactions.removeAll { $0.id == id }
    }

    public func deleteAll() async throws {
        transactions.removeAll()
    }

    public func fetchRecent(limit: Int = 100) async throws -> [NetworkTransaction] {
        let recent = Array(transactions.suffix(limit))
        return recent.compactMap(convertToEntity)
    }

    public func fetchByMethod(_ method: String) async throws -> [NetworkTransaction] {
        let filtered = transactions.filter { $0.method == method }
        return filtered.compactMap(convertToEntity)
    }

    public func fetchByStatusCode(_ statusCode: Int) async throws -> [NetworkTransaction] {
        let filtered = transactions.filter { $0.statusCode == statusCode }
        return filtered.compactMap(convertToEntity)
    }

    public func fetchFiltered(by filter: TransactionFilter) async throws -> [NetworkTransaction] {
        var filtered = transactions

        if let method = filter.method {
            filtered = filtered.filter { $0.method == method.rawValue }
        }

        if let statusCode = filter.statusCode {
            filtered = filtered.filter { $0.statusCode == statusCode }
        }

        if let searchTerm = filter.searchTerm, !searchTerm.isEmpty {
            filtered = filtered.filter {
                $0.url.lowercased().contains(searchTerm.lowercased()) ||
                $0.method.lowercased().contains(searchTerm.lowercased())
            }
        }

        if let timeRange = filter.timeRange {
            filtered = filtered.filter { transaction in
                timeRange.contains(transaction.startTime)
            }
        }

        return filtered.compactMap(convertToEntity)
    }

    private func convertToEntity(_ data: NetworkTransactionData) -> NetworkTransaction? {
        guard let method = HTTPMethod(rawValue: data.method),
              let status = TransactionStatus(rawValue: data.status) else {
            return nil
        }

        let request = NetworkRequest(
            url: data.url,
            method: method,
            headers: data.requestHeaders,
            body: data.requestBody
        )

        let response: NetworkResponse?
        if let statusCode = data.statusCode {
            response = NetworkResponse(
                statusCode: statusCode,
                headers: data.responseHeaders ?? [:],
                body: data.responseBody,
                responseTime: data.endTime?.timeIntervalSince(data.startTime) ?? 0
            )
        } else {
            response = nil
        }

        return NetworkTransaction(
            id: data.id,
            request: request,
            response: response,
            status: status,
            startTime: data.startTime,
            endTime: data.endTime
        )
    }
}
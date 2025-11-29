import Foundation
import JarvisCommon
import JarvisData
import JarvisDomain
import JarvisInspectorDomain

/// Repository for network transaction data with Core Data persistent storage
/// Now uses Core Data for all iOS versions (iOS 13+) - no more iOS 17 checks or in-memory fallback
public class NetworkTransactionRepository: NetworkTransactionRepositoryProtocol {

    public init() {
        // Using Core Data persistent storage for all iOS versions
    }

    public func save(_ transaction: NetworkTransaction) async throws {
        let entity = NetworkTransactionEntity(
            id: transaction.id,
            requestId: UUID().uuidString,
            responseId: transaction.response != nil ? UUID().uuidString : nil,
            method: transaction.request.method.rawValue,
            url: transaction.request.url,
            requestHeadersJSON: NetworkTransactionEntity.encodeHeaders(transaction.request.headers),
            responseHeadersJSON: transaction.response.map { NetworkTransactionEntity.encodeHeaders($0.headers) },
            requestBody: transaction.request.body,
            responseBody: transaction.response?.body,
            statusCode: transaction.response?.statusCode,
            startTime: transaction.startTime,
            endTime: transaction.endTime,
            status: transaction.status.rawValue,
            httpProtocol: transaction.request.httpProtocol,
            path: transaction.request.path,
            host: transaction.request.host,
            requestTimestamp: transaction.request.timestamp,
            requestBodySize: Int64(transaction.request.bodySize),
            responseTimestamp: transaction.response?.timestamp ?? 0,
            responseBodySize: Int64(transaction.response?.bodySize ?? 0),
            statusMessage: transaction.response?.statusMessage,
            error: transaction.error
        )

        try await MainActor.run {
            try NetworkTransactionStorage.shared.save(entity)
        }
    }

    public func fetch(id: String) async throws -> NetworkTransaction? {
        return try await MainActor.run {
            guard let entity = try NetworkTransactionStorage.shared.fetch(id: id) else {
                return nil
            }
            return convertEntityToTransaction(entity)
        }
    }

    public func fetchAll() async throws -> [NetworkTransaction] {
        return try await MainActor.run {
            let entities = try NetworkTransactionStorage.shared.fetchAll()
            return entities.compactMap(convertEntityToTransaction)
        }
    }

    public func delete(id: String) async throws {
        try await MainActor.run {
            try NetworkTransactionStorage.shared.delete(id: id)
        }
    }

    public func deleteAll() async throws {
        try await MainActor.run {
            try NetworkTransactionStorage.shared.deleteAll()
        }
    }

    public func fetchRecent(limit: Int = 100) async throws -> [NetworkTransaction] {
        return try await MainActor.run {
            let entities = try NetworkTransactionStorage.shared.fetchRecent(limit: limit)
            return entities.compactMap(convertEntityToTransaction)
        }
    }

    public func fetchByMethod(_ method: String) async throws -> [NetworkTransaction] {
        return try await MainActor.run {
            let entities = try NetworkTransactionStorage.shared.fetchByMethod(method)
            return entities.compactMap(convertEntityToTransaction)
        }
    }

    public func fetchByStatusCode(_ statusCode: Int) async throws -> [NetworkTransaction] {
        return try await MainActor.run {
            let entities = try NetworkTransactionStorage.shared.fetchByStatusCode(statusCode)
            return entities.compactMap(convertEntityToTransaction)
        }
    }

    public func fetchFiltered(by filter: TransactionFilter) async throws -> [NetworkTransaction] {
        return try await MainActor.run {
            var entities = try NetworkTransactionStorage.shared.fetchAll()

            // Apply filters
            if let method = filter.method {
                entities = entities.filter { $0.method == method.rawValue }
            }

            if let statusCode = filter.statusCode {
                entities = entities.filter { $0.statusCode == statusCode }
            }

            if let searchTerm = filter.searchTerm, !searchTerm.isEmpty {
                entities = entities.filter {
                    $0.url.lowercased().contains(searchTerm.lowercased()) ||
                    $0.method.lowercased().contains(searchTerm.lowercased())
                }
            }

            if let timeRange = filter.timeRange {
                entities = entities.filter { entity in
                    timeRange.contains(entity.startTime)
                }
            }

            return entities.compactMap(convertEntityToTransaction)
        }
    }

    public func deleteOldTransactions(beforeTimestamp: TimeInterval) async throws {
        try await MainActor.run {
            try NetworkTransactionStorage.shared.deleteOldTransactions(beforeTimestamp: beforeTimestamp)
        }
    }

    // MARK: - Conversion Helpers

    private func convertEntityToTransaction(_ entity: NetworkTransactionEntity) -> NetworkTransaction? {
        guard let method = HTTPMethod(rawValue: entity.method),
              let status = TransactionStatus(rawValue: entity.status) else {
            return nil
        }

        let requestHeaders = NetworkTransactionEntity.decodeHeaders(entity.requestHeadersJSON)
        let responseHeaders = entity.responseHeadersJSON.map { NetworkTransactionEntity.decodeHeaders($0) }

        let request = NetworkRequest(
            url: entity.url,
            method: method,
            headers: requestHeaders,
            body: entity.requestBody,
            httpProtocol: entity.httpProtocol,
            path: entity.path,
            host: entity.host,
            timestamp: entity.requestTimestamp
        )

        let response: NetworkResponse?
        if let statusCode = entity.statusCode {
            response = NetworkResponse(
                statusCode: statusCode,
                headers: responseHeaders ?? [:],
                body: entity.responseBody,
                responseTime: entity.endTime?.timeIntervalSince(entity.startTime) ?? 0,
                statusMessage: entity.statusMessage,
                timestamp: entity.responseTimestamp
            )
        } else {
            response = nil
        }

        return NetworkTransaction(
            id: entity.id,
            request: request,
            response: response,
            status: status,
            startTime: entity.startTime,
            endTime: entity.endTime,
            error: entity.error
        )
    }
}

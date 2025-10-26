import Foundation
import Common
import Data
import Domain
import JarvisInspectorDomain

/// Repository for network transaction data with persistent storage
public class NetworkTransactionRepository: NetworkTransactionRepositoryProtocol {

    // Fallback in-memory storage for iOS < 17
    private var inMemoryTransactions: [NetworkTransactionData] = []

    public init() {
        // Using SwiftData persistent storage on iOS 17+, in-memory on older versions
    }

    public func save(_ transaction: NetworkTransaction) async throws {
        if #available(iOS 17.0, *) {
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
                status: transaction.status.rawValue
            )

            try await MainActor.run {
                try NetworkTransactionStorage.shared.save(entity)
            }
        } else {
            // Fallback to in-memory storage
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
            inMemoryTransactions.append(data)
        }
    }

    public func fetch(id: String) async throws -> NetworkTransaction? {
        if #available(iOS 17.0, *) {
            return try await MainActor.run {
                guard let entity = try NetworkTransactionStorage.shared.fetch(id: id) else {
                    return nil
                }
                return convertEntityToTransaction(entity)
            }
        } else {
            if let data = inMemoryTransactions.first(where: { $0.id == id }) {
                return convertDataToTransaction(data)
            }
            return nil
        }
    }

    public func fetchAll() async throws -> [NetworkTransaction] {
        if #available(iOS 17.0, *) {
            return try await MainActor.run {
                let entities = try NetworkTransactionStorage.shared.fetchAll()
                return entities.compactMap(convertEntityToTransaction)
            }
        } else {
            return inMemoryTransactions.compactMap(convertDataToTransaction)
        }
    }

    public func delete(id: String) async throws {
        if #available(iOS 17.0, *) {
            try await MainActor.run {
                try NetworkTransactionStorage.shared.delete(id: id)
            }
        } else {
            inMemoryTransactions.removeAll { $0.id == id }
        }
    }

    public func deleteAll() async throws {
        if #available(iOS 17.0, *) {
            try await MainActor.run {
                try NetworkTransactionStorage.shared.deleteAll()
            }
        } else {
            inMemoryTransactions.removeAll()
        }
    }

    public func fetchRecent(limit: Int = 100) async throws -> [NetworkTransaction] {
        if #available(iOS 17.0, *) {
            return try await MainActor.run {
                let entities = try NetworkTransactionStorage.shared.fetchRecent(limit: limit)
                return entities.compactMap(convertEntityToTransaction)
            }
        } else {
            let recent = Array(inMemoryTransactions.suffix(limit))
            return recent.compactMap(convertDataToTransaction)
        }
    }

    public func fetchByMethod(_ method: String) async throws -> [NetworkTransaction] {
        if #available(iOS 17.0, *) {
            return try await MainActor.run {
                let entities = try NetworkTransactionStorage.shared.fetchByMethod(method)
                return entities.compactMap(convertEntityToTransaction)
            }
        } else {
            let filtered = inMemoryTransactions.filter { $0.method == method }
            return filtered.compactMap(convertDataToTransaction)
        }
    }

    public func fetchByStatusCode(_ statusCode: Int) async throws -> [NetworkTransaction] {
        if #available(iOS 17.0, *) {
            return try await MainActor.run {
                let entities = try NetworkTransactionStorage.shared.fetchByStatusCode(statusCode)
                return entities.compactMap(convertEntityToTransaction)
            }
        } else {
            let filtered = inMemoryTransactions.filter { $0.statusCode == statusCode }
            return filtered.compactMap(convertDataToTransaction)
        }
    }

    public func fetchFiltered(by filter: TransactionFilter) async throws -> [NetworkTransaction] {
        if #available(iOS 17.0, *) {
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
        } else {
            var filtered = inMemoryTransactions

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

            return filtered.compactMap(convertDataToTransaction)
        }
    }

    // MARK: - Conversion Helpers

    @available(iOS 17.0, *)
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
            body: entity.requestBody
        )

        let response: NetworkResponse?
        if let statusCode = entity.statusCode {
            response = NetworkResponse(
                statusCode: statusCode,
                headers: responseHeaders ?? [:],
                body: entity.responseBody,
                responseTime: entity.endTime?.timeIntervalSince(entity.startTime) ?? 0
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
            endTime: entity.endTime
        )
    }

    private func convertDataToTransaction(_ data: NetworkTransactionData) -> NetworkTransaction? {
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

import Foundation
import JarvisCommon
import JarvisDomain

/// Network inspector domain layer
/// Contains business logic for network monitoring and inspection
public struct JarvisInspectorDomain {
    public static let version = "1.0.0"
}

// MARK: - Inspector Entities

/// Network transaction entity (combines request and response)
public struct NetworkTransaction {
    public let id: String
    public let request: NetworkRequest
    public let response: NetworkResponse?
    public let status: TransactionStatus
    public let startTime: Date
    public let endTime: Date?

    public init(
        id: String = UUID().uuidString,
        request: NetworkRequest,
        response: NetworkResponse? = nil,
        status: TransactionStatus,
        startTime: Date = Date(),
        endTime: Date? = nil
    ) {
        self.id = id
        self.request = request
        self.response = response
        self.status = status
        self.startTime = startTime
        self.endTime = endTime
    }

    public var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }

    public var isCompleted: Bool {
        status == .completed
    }

    public var isSuccessful: Bool {
        guard let response = response else { return false }
        return response.statusCode >= 200 && response.statusCode < 300
    }
}

/// Transaction status
public enum TransactionStatus: String, CaseIterable {
    case pending = "pending"
    case completed = "completed"
    case failed = "failed"
    case cancelled = "cancelled"
}

// MARK: - Use Cases

/// Monitor network transactions use case
public struct MonitorNetworkTransactionsUseCase: UseCase {
    public typealias Input = Void
    public typealias Output = [NetworkTransaction]

    public init() {}

    public func execute(_ input: Void) async throws -> [NetworkTransaction] {
        // Implementation will be added later
        return []
    }
}

/// Get network transaction details use case
public struct GetNetworkTransactionUseCase: UseCase {
    public typealias Input = String // Transaction ID
    public typealias Output = NetworkTransaction?

    public init() {}

    public func execute(_ input: String) async throws -> NetworkTransaction? {
        // Implementation will be added later
        return nil
    }
}

/// Filter network transactions use case
public struct FilterNetworkTransactionsUseCase: UseCase {
    public typealias Input = TransactionFilter
    public typealias Output = [NetworkTransaction]

    public init() {}

    public func execute(_ input: TransactionFilter) async throws -> [NetworkTransaction] {
        // Implementation will be added later
        return []
    }
}

// MARK: - Filter Types

public struct TransactionFilter {
    public let method: HTTPMethod?
    public let statusCode: Int?
    public let searchTerm: String?
    public let timeRange: DateInterval?

    public init(
        method: HTTPMethod? = nil,
        statusCode: Int? = nil,
        searchTerm: String? = nil,
        timeRange: DateInterval? = nil
    ) {
        self.method = method
        self.statusCode = statusCode
        self.searchTerm = searchTerm
        self.timeRange = timeRange
    }
}
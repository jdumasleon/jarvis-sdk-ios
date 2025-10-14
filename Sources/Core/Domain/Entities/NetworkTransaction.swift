import Foundation
import Common

/// Represents a complete network transaction (request + response)
public struct NetworkTransaction: Identifiable, Equatable, Hashable {
    public let id: String
    public let request: NetworkRequest
    public let response: NetworkResponse?
    public let status: TransactionStatus
    public let startTime: Date
    public let endTime: Date?
    public let duration: TimeInterval?

    public init(
        id: String = UUID().uuidString,
        request: NetworkRequest,
        response: NetworkResponse? = nil,
        status: TransactionStatus = .pending,
        startTime: Date = Date(),
        endTime: Date? = nil
    ) {
        self.id = id
        self.request = request
        self.response = response
        self.status = status
        self.startTime = startTime
        self.endTime = endTime
        self.duration = endTime?.timeIntervalSince(startTime)
    }

    /// Update transaction with response
    public func withResponse(_ response: NetworkResponse, endTime: Date = Date()) -> NetworkTransaction {
        return NetworkTransaction(
            id: id,
            request: request,
            response: response,
            status: response.statusCode >= 200 && response.statusCode < 300 ? .completed : .failed,
            startTime: startTime,
            endTime: endTime
        )
    }

    /// Mark transaction as failed
    public func markAsFailed(endTime: Date = Date()) -> NetworkTransaction {
        return NetworkTransaction(
            id: id,
            request: request,
            response: response,
            status: .failed,
            startTime: startTime,
            endTime: endTime
        )
    }
}

/// Network request details
public struct NetworkRequest: Equatable, Hashable {
    public let url: String
    public let method: HTTPMethod
    public let headers: [String: String]
    public let body: Data?
    public let bodyString: String?

    public init(
        url: String,
        method: HTTPMethod,
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.bodyString = body?.prettyPrintedJSON ?? body.flatMap { String(data: $0, encoding: .utf8) }
    }

    /// Content type from headers
    public var contentType: String? {
        return headers["Content-Type"] ?? headers["content-type"]
    }

    /// Content length from headers or body
    public var contentLength: Int {
        if let lengthString = headers["Content-Length"] ?? headers["content-length"],
           let length = Int(lengthString) {
            return length
        }
        return body?.count ?? 0
    }
}

/// Network response details
public struct NetworkResponse: Equatable, Hashable {
    public let statusCode: Int
    public let headers: [String: String]
    public let body: Data?
    public let bodyString: String?
    public let responseTime: TimeInterval

    public init(
        statusCode: Int,
        headers: [String: String] = [:],
        body: Data? = nil,
        responseTime: TimeInterval
    ) {
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
        self.bodyString = body?.prettyPrintedJSON ?? body.flatMap { String(data: $0, encoding: .utf8) }
        self.responseTime = responseTime
    }

    /// Content type from headers
    public var contentType: String? {
        return headers["Content-Type"] ?? headers["content-type"]
    }

    /// Content length from headers or body
    public var contentLength: Int {
        if let lengthString = headers["Content-Length"] ?? headers["content-length"],
           let length = Int(lengthString) {
            return length
        }
        return body?.count ?? 0
    }

    /// Check if response indicates success
    public var isSuccess: Bool {
        return statusCode >= 200 && statusCode < 300
    }

    /// Status code category
    public var statusCategory: StatusCategory {
        switch statusCode {
        case 100..<200:
            return .informational
        case 200..<300:
            return .success
        case 300..<400:
            return .redirection
        case 400..<500:
            return .clientError
        case 500..<600:
            return .serverError
        default:
            return .unknown
        }
    }
}

/// HTTP methods
public enum HTTPMethod: String, CaseIterable, Equatable, Hashable {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
    case HEAD = "HEAD"
    case OPTIONS = "OPTIONS"
    case TRACE = "TRACE"
    case CONNECT = "CONNECT"

    public var displayName: String {
        return rawValue
    }
}

/// Transaction status
public enum TransactionStatus: String, CaseIterable, Equatable, Hashable {
    case pending = "pending"
    case completed = "completed"
    case failed = "failed"
    case cancelled = "cancelled"

    public var displayName: String {
        switch self {
        case .pending:
            return "Pending"
        case .completed:
            return "Completed"
        case .failed:
            return "Failed"
        case .cancelled:
            return "Cancelled"
        }
    }
}

/// HTTP status code categories
public enum StatusCategory: String, CaseIterable, Equatable, Hashable {
    case informational = "1xx"
    case success = "2xx"
    case redirection = "3xx"
    case clientError = "4xx"
    case serverError = "5xx"
    case unknown = "unknown"

    public var displayName: String {
        switch self {
        case .informational:
            return "Informational"
        case .success:
            return "Success"
        case .redirection:
            return "Redirection"
        case .clientError:
            return "Client Error"
        case .serverError:
            return "Server Error"
        case .unknown:
            return "Unknown"
        }
    }
}

// MARK: - Mock Data
public extension NetworkTransaction {
    static let mockTransactions: [NetworkTransaction] = [
        NetworkTransaction(
            id: "1",
            request: NetworkRequest(
                url: "https://api.example.com/users",
                method: .GET,
                headers: ["Authorization": "Bearer token123"]
            ),
            response: NetworkResponse(
                statusCode: 200,
                headers: ["Content-Type": "application/json"],
                body: """
                {"users": [{"id": 1, "name": "John"}]}
                """.data(using: .utf8),
                responseTime: 245
            ),
            status: .completed,
            startTime: Date().addingTimeInterval(-300),
            endTime: Date().addingTimeInterval(-300 + 0.245)
        ),
        NetworkTransaction(
            id: "2",
            request: NetworkRequest(
                url: "https://api.example.com/posts",
                method: .POST,
                headers: ["Content-Type": "application/json"],
                body: """
                {"title": "New Post", "content": "Post content"}
                """.data(using: .utf8)
            ),
            response: NetworkResponse(
                statusCode: 201,
                headers: ["Content-Type": "application/json"],
                body: """
                {"id": 123, "status": "created"}
                """.data(using: .utf8),
                responseTime: 156
            ),
            status: .completed,
            startTime: Date().addingTimeInterval(-180),
            endTime: Date().addingTimeInterval(-180 + 0.156)
        ),
        NetworkTransaction(
            id: "3",
            request: NetworkRequest(
                url: "https://api.example.com/data",
                method: .GET
            ),
            response: nil,
            status: .failed,
            startTime: Date().addingTimeInterval(-60),
            endTime: Date().addingTimeInterval(-50)
        )
    ]
}
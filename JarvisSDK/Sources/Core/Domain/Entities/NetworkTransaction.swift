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
    public let error: String?

    public init(
        id: String = UUID().uuidString,
        request: NetworkRequest,
        response: NetworkResponse? = nil,
        status: TransactionStatus = .pending,
        startTime: Date = Date(),
        endTime: Date? = nil,
        error: String? = nil
    ) {
        self.id = id
        self.request = request
        self.response = response
        self.status = status
        self.startTime = startTime
        self.endTime = endTime
        self.duration = endTime?.timeIntervalSince(startTime)
        self.error = error
    }

    /// Update transaction with response
    public func withResponse(_ response: NetworkResponse, endTime: Date = Date()) -> NetworkTransaction {
        return NetworkTransaction(
            id: id,
            request: request,
            response: response,
            status: response.statusCode >= 200 && response.statusCode < 300 ? .completed : .failed,
            startTime: startTime,
            endTime: endTime,
            error: error
        )
    }

    /// Mark transaction as failed
    public func markAsFailed(endTime: Date = Date(), error: String? = nil) -> NetworkTransaction {
        return NetworkTransaction(
            id: id,
            request: request,
            response: response,
            status: .failed,
            startTime: startTime,
            endTime: endTime,
            error: error ?? self.error
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
    public let httpProtocol: String
    public let path: String
    public let host: String
    public let timestamp: Int64
    public let bodySize: Int
    public let hasBody: Bool

    public init(
        url: String,
        method: HTTPMethod,
        headers: [String: String] = [:],
        body: Data? = nil,
        httpProtocol: String? = nil,
        path: String? = nil,
        host: String? = nil,
        timestamp: Int64? = nil
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.bodyString = body?.prettyPrintedJSON ?? body.flatMap { String(data: $0, encoding: .utf8) }

        // Extract protocol, path, host from URL if not provided
        if let urlComponents = URLComponents(string: url) {
            self.httpProtocol = httpProtocol ?? urlComponents.scheme?.uppercased() ?? "HTTP/1.1"
            self.path = path ?? (urlComponents.path.isEmpty ? "/" : urlComponents.path)
            self.host = host ?? urlComponents.host ?? ""
        } else {
            self.httpProtocol = httpProtocol ?? "HTTP/1.1"
            self.path = path ?? "/"
            self.host = host ?? ""
        }

        self.timestamp = timestamp ?? Int64(Date().timeIntervalSince1970 * 1000)
        self.bodySize = body?.count ?? 0
        self.hasBody = body != nil && !(body?.isEmpty ?? true)
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
    public let statusMessage: String
    public let timestamp: Int64
    public let bodySize: Int
    public let hasBody: Bool

    public init(
        statusCode: Int,
        headers: [String: String] = [:],
        body: Data? = nil,
        responseTime: TimeInterval,
        statusMessage: String? = nil,
        timestamp: Int64? = nil
    ) {
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
        self.bodyString = body?.prettyPrintedJSON ?? body.flatMap { String(data: $0, encoding: .utf8) }
        self.responseTime = responseTime
        self.statusMessage = statusMessage ?? Self.defaultStatusMessage(for: statusCode)
        self.timestamp = timestamp ?? Int64(Date().timeIntervalSince1970 * 1000)
        self.bodySize = body?.count ?? 0
        self.hasBody = body != nil && !(body?.isEmpty ?? true)
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

    /// Alias for isSuccess (Android compatibility)
    public var isSuccessful: Bool {
        return isSuccess
    }

    /// Check if content is JSON
    public var isJson: Bool {
        guard let contentType = contentType else { return false }
        return contentType.contains("application/json") ||
               contentType.contains("application/vnd.api+json") ||
               contentType.contains("text/json")
    }

    /// Check if content is XML
    public var isXml: Bool {
        guard let contentType = contentType else { return false }
        return contentType.contains("application/xml") ||
               contentType.contains("text/xml") ||
               contentType.contains("application/xhtml+xml")
    }

    /// Check if content is an image
    public var isImage: Bool {
        guard let contentType = contentType else { return false }
        return contentType.hasPrefix("image/")
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

    /// Get default status message for status code
    private static func defaultStatusMessage(for statusCode: Int) -> String {
        switch statusCode {
        case 100: return "Continue"
        case 101: return "Switching Protocols"
        case 200: return "OK"
        case 201: return "Created"
        case 202: return "Accepted"
        case 204: return "No Content"
        case 301: return "Moved Permanently"
        case 302: return "Found"
        case 304: return "Not Modified"
        case 307: return "Temporary Redirect"
        case 308: return "Permanent Redirect"
        case 400: return "Bad Request"
        case 401: return "Unauthorized"
        case 403: return "Forbidden"
        case 404: return "Not Found"
        case 405: return "Method Not Allowed"
        case 408: return "Request Timeout"
        case 409: return "Conflict"
        case 410: return "Gone"
        case 422: return "Unprocessable Entity"
        case 429: return "Too Many Requests"
        case 500: return "Internal Server Error"
        case 501: return "Not Implemented"
        case 502: return "Bad Gateway"
        case 503: return "Service Unavailable"
        case 504: return "Gateway Timeout"
        default: return "Unknown"
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
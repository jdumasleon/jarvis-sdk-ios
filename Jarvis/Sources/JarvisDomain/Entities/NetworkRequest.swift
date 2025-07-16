import Foundation

public struct NetworkRequest: Identifiable, Hashable {
    public let id = UUID()
    public let url: URL
    public let method: HTTPMethod
    public let headers: [String: String]
    public let body: Data?
    public let timestamp: Date
    
    public init(
        url: URL,
        method: HTTPMethod,
        headers: [String: String] = [:],
        body: Data? = nil,
        timestamp: Date = Date()
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.timestamp = timestamp
    }
}

public struct NetworkResponse: Identifiable, Hashable {
    public let id = UUID()
    public let requestId: UUID
    public let statusCode: Int
    public let headers: [String: String]
    public let body: Data?
    public let responseTime: TimeInterval
    public let timestamp: Date
    
    public init(
        requestId: UUID,
        statusCode: Int,
        headers: [String: String] = [:],
        body: Data? = nil,
        responseTime: TimeInterval,
        timestamp: Date = Date()
    ) {
        self.requestId = requestId
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
        self.responseTime = responseTime
        self.timestamp = timestamp
    }
}

public enum HTTPMethod: String, CaseIterable, Hashable {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
    case HEAD = "HEAD"
    case OPTIONS = "OPTIONS"
}
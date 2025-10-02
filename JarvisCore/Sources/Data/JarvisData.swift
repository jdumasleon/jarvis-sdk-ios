import Foundation

/// Data layer for the Jarvis SDK
/// Handles network requests, data storage, and API communication
public struct JarvisData {
    public static let version = "1.0.0"
}

// MARK: - Data Models

/// Base protocol for all Jarvis data models
public protocol JarvisModel: Codable, Identifiable {
    var id: String { get }
}

/// Network request data model
public struct NetworkRequestData: JarvisModel {
    public let id: String
    public let url: String
    public let method: String
    public let headers: [String: String]
    public let body: Data?
    public let timestamp: Date

    public init(
        id: String = UUID().uuidString,
        url: String,
        method: String,
        headers: [String: String] = [:],
        body: Data? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.timestamp = timestamp
    }
}

/// Network response data model
public struct NetworkResponseData: JarvisModel {
    public let id: String
    public let requestId: String
    public let statusCode: Int
    public let headers: [String: String]
    public let body: Data?
    public let duration: TimeInterval
    public let timestamp: Date

    public init(
        id: String = UUID().uuidString,
        requestId: String,
        statusCode: Int,
        headers: [String: String] = [:],
        body: Data? = nil,
        duration: TimeInterval,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.requestId = requestId
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
        self.duration = duration
        self.timestamp = timestamp
    }
}

// MARK: - Repository Protocol

/// Protocol for data repositories
public protocol Repository {
    associatedtype Model: JarvisModel

    func save(_ model: Model) async throws
    func fetch(id: String) async throws -> Model?
    func fetchAll() async throws -> [Model]
    func delete(id: String) async throws
    func deleteAll() async throws
}
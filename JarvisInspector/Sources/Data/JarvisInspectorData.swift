import Foundation
import JarvisCommon
import JarvisData
import JarvisPlatform
import JarvisInspectorDomain

/// Network inspector data layer
/// Handles network interception, data persistence, and storage
public struct JarvisInspectorData {
    public static let version = "1.0.0"
}

// MARK: - Data Models

/// Network transaction data model
public struct NetworkTransactionData: JarvisModel {
    public let id: String
    public let requestId: String
    public let responseId: String?
    public let method: String
    public let url: String
    public let requestHeaders: [String: String]
    public let requestBody: Data?
    public let responseHeaders: [String: String]?
    public let responseBody: Data?
    public let statusCode: Int?
    public let startTime: Date
    public let endTime: Date?
    public let status: String

    public init(
        id: String = UUID().uuidString,
        requestId: String,
        responseId: String? = nil,
        method: String,
        url: String,
        requestHeaders: [String: String] = [:],
        requestBody: Data? = nil,
        responseHeaders: [String: String]? = nil,
        responseBody: Data? = nil,
        statusCode: Int? = nil,
        startTime: Date = Date(),
        endTime: Date? = nil,
        status: String
    ) {
        self.id = id
        self.requestId = requestId
        self.responseId = responseId
        self.method = method
        self.url = url
        self.requestHeaders = requestHeaders
        self.requestBody = requestBody
        self.responseHeaders = responseHeaders
        self.responseBody = responseBody
        self.statusCode = statusCode
        self.startTime = startTime
        self.endTime = endTime
        self.status = status
    }
}

// MARK: - Repository Implementation

/// Repository for network transaction data
public class NetworkTransactionRepository: Repository {
    public typealias Model = NetworkTransactionData

    public init() {}

    public func save(_ model: NetworkTransactionData) async throws {
        // Implementation will be added later
    }

    public func fetch(id: String) async throws -> NetworkTransactionData? {
        // Implementation will be added later
        return nil
    }

    public func fetchAll() async throws -> [NetworkTransactionData] {
        // Implementation will be added later
        return []
    }

    public func delete(id: String) async throws {
        // Implementation will be added later
    }

    public func deleteAll() async throws {
        // Implementation will be added later
    }

    public func fetchRecent(limit: Int = 100) async throws -> [NetworkTransactionData] {
        // Implementation will be added later
        return []
    }

    public func fetchByMethod(_ method: String) async throws -> [NetworkTransactionData] {
        // Implementation will be added later
        return []
    }

    public func fetchByStatusCode(_ statusCode: Int) async throws -> [NetworkTransactionData] {
        // Implementation will be added later
        return []
    }
}

// MARK: - Network Interceptor

/// Network traffic interceptor
public class NetworkInterceptor {
    public static let shared = NetworkInterceptor()

    private var isMonitoring = false
    private let repository = NetworkTransactionRepository()

    private init() {}

    public func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true

        // Register URL protocol for interception
        URLProtocol.registerClass(URLSessionInterceptor.self)

        // Set up callbacks
        URLSessionInterceptor.onRequestStarted = { [weak self] request in
            self?.handleRequestStarted(request)
        }

        URLSessionInterceptor.onRequestCompleted = { [weak self] request, response, data, error in
            self?.handleRequestCompleted(request, response, data, error)
        }
    }

    public func stopMonitoring() {
        guard isMonitoring else { return }
        isMonitoring = false

        URLProtocol.unregisterClass(URLSessionInterceptor.self)
        URLSessionInterceptor.onRequestStarted = nil
        URLSessionInterceptor.onRequestCompleted = nil
    }

    private func handleRequestStarted(_ request: URLRequest) {
        Task {
            let transactionData = NetworkTransactionData(
                requestId: UUID().uuidString,
                method: request.httpMethod ?? "GET",
                url: request.url?.absoluteString ?? "",
                requestHeaders: request.allHTTPHeaderFields ?? [:],
                requestBody: request.httpBody,
                status: "pending"
            )

            try? await repository.save(transactionData)
        }
    }

    private func handleRequestCompleted(
        _ request: URLRequest,
        _ response: URLResponse?,
        _ data: Data?,
        _ error: Error?
    ) {
        Task {
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            let responseHeaders = (response as? HTTPURLResponse)?.allHeaderFields as? [String: String]

            let transactionData = NetworkTransactionData(
                requestId: UUID().uuidString,
                responseId: UUID().uuidString,
                method: request.httpMethod ?? "GET",
                url: request.url?.absoluteString ?? "",
                requestHeaders: request.allHTTPHeaderFields ?? [:],
                requestBody: request.httpBody,
                responseHeaders: responseHeaders ?? [:],
                responseBody: data,
                statusCode: statusCode,
                endTime: Date(),
                status: error != nil ? "failed" : "completed"
            )

            try? await repository.save(transactionData)
        }
    }
}
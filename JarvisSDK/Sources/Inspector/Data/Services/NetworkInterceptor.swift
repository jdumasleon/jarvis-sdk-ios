import Foundation
import Platform
import Domain
import JarvisInspectorDomain

/// Network traffic interceptor
public class NetworkInterceptor {
    public static let shared = NetworkInterceptor()

    private var isMonitoring = false
    private let repository: NetworkTransactionRepositoryProtocol

    // Track request start times for accurate duration calculation
    private var requestStartTimes: [String: TimeInterval] = [:]
    private let timingQueue = DispatchQueue(label: "com.jarvis.inspector.timing", attributes: .concurrent)

    public init(repository: NetworkTransactionRepositoryProtocol = NetworkTransactionRepository()) {
        self.repository = repository
    }

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
        // Capture precise start time immediately
        let startTime = Date().timeIntervalSince1970
        let requestId = generateRequestId(from: request)

        // Store start time for duration calculation
        timingQueue.async(flags: .barrier) { [weak self] in
            self?.requestStartTimes[requestId] = startTime
        }

        Task {
            // Redact sensitive headers
            let originalHeaders = request.allHTTPHeaderFields ?? [:]
            let redactedHeaders = HeaderRedaction.redactHeaders(originalHeaders)

            // Redact sensitive body data if needed
            let redactedBody = HeaderRedaction.redactBodyIfNeeded(request.httpBody)

            // Truncate large bodies to prevent memory issues
            let truncatedBody = BodyTruncation.truncateIfNeeded(redactedBody)

            let networkRequest = NetworkRequest(
                url: request.url?.absoluteString ?? "",
                method: HTTPMethod(rawValue: request.httpMethod ?? "GET") ?? .GET,
                headers: redactedHeaders,
                body: truncatedBody
            )

            let transaction = NetworkTransaction(
                id: requestId,
                request: networkRequest,
                status: .pending,
                startTime: Date(timeIntervalSince1970: startTime)
            )

            try? await repository.save(transaction)
        }
    }

    private func handleRequestCompleted(
        _ request: URLRequest,
        _ response: URLResponse?,
        _ data: Data?,
        _ error: Error?
    ) {
        // Capture precise end time immediately
        let endTime = Date().timeIntervalSince1970
        let requestId = generateRequestId(from: request)

        // Retrieve start time and calculate accurate duration
        var startTime: TimeInterval = endTime
        var responseTime: TimeInterval = 0

        timingQueue.sync { [weak self] in
            if let storedStartTime = self?.requestStartTimes[requestId] {
                startTime = storedStartTime
                responseTime = endTime - storedStartTime
            }
        }

        // Clean up stored timing
        timingQueue.async(flags: .barrier) { [weak self] in
            self?.requestStartTimes.removeValue(forKey: requestId)
        }

        Task {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            let originalResponseHeaders = (response as? HTTPURLResponse)?.allHeaderFields as? [String: String]

            // Redact request headers
            let originalRequestHeaders = request.allHTTPHeaderFields ?? [:]
            let redactedRequestHeaders = HeaderRedaction.redactHeaders(originalRequestHeaders)

            // Redact request body
            let redactedRequestBody = HeaderRedaction.redactBodyIfNeeded(request.httpBody)

            // Truncate request body
            let truncatedRequestBody = BodyTruncation.truncateIfNeeded(redactedRequestBody)

            // Redact response headers
            let redactedResponseHeaders = HeaderRedaction.redactHeaders(originalResponseHeaders ?? [:])

            // Redact response body
            let redactedResponseBody = HeaderRedaction.redactBodyIfNeeded(data)

            // Truncate response body
            let truncatedResponseBody = BodyTruncation.truncateIfNeeded(redactedResponseBody)

            let networkRequest = NetworkRequest(
                url: request.url?.absoluteString ?? "",
                method: HTTPMethod(rawValue: request.httpMethod ?? "GET") ?? .GET,
                headers: redactedRequestHeaders,
                body: truncatedRequestBody
            )

            let networkResponse: NetworkResponse? = statusCode > 0 ? NetworkResponse(
                statusCode: statusCode,
                headers: redactedResponseHeaders,
                body: truncatedResponseBody,
                responseTime: responseTime // Accurate duration!
            ) : nil

            let status: TransactionStatus = error != nil ? .failed : .completed

            let transaction = NetworkTransaction(
                id: requestId,
                request: networkRequest,
                response: networkResponse,
                status: status,
                startTime: Date(timeIntervalSince1970: startTime),
                endTime: Date(timeIntervalSince1970: endTime)
            )

            try? await repository.save(transaction)
        }
    }

    /// Generates a unique identifier for a request
    private func generateRequestId(from request: URLRequest) -> String {
        let url = request.url?.absoluteString ?? ""
        let method = request.httpMethod ?? "GET"
        let timestamp = Date().timeIntervalSince1970
        return "\(method)_\(url)_\(timestamp)".data(using: .utf8)?.base64EncodedString() ?? UUID().uuidString
    }
}
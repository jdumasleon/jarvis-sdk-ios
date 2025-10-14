import Foundation
import Platform
import Domain
import JarvisInspectorDomain

/// Network traffic interceptor
public class NetworkInterceptor {
    public static let shared = NetworkInterceptor()

    private var isMonitoring = false
    private let repository: NetworkTransactionRepositoryProtocol

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
        Task {
            let networkRequest = NetworkRequest(
                url: request.url?.absoluteString ?? "",
                method: HTTPMethod(rawValue: request.httpMethod ?? "GET") ?? .GET,
                headers: request.allHTTPHeaderFields ?? [:],
                body: request.httpBody
            )

            let transaction = NetworkTransaction(
                request: networkRequest,
                status: .pending
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
        Task {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            let responseHeaders = (response as? HTTPURLResponse)?.allHeaderFields as? [String: String]

            let networkRequest = NetworkRequest(
                url: request.url?.absoluteString ?? "",
                method: HTTPMethod(rawValue: request.httpMethod ?? "GET") ?? .GET,
                headers: request.allHTTPHeaderFields ?? [:],
                body: request.httpBody
            )

            let networkResponse: NetworkResponse? = statusCode > 0 ? NetworkResponse(
                statusCode: statusCode,
                headers: responseHeaders ?? [:],
                body: data,
                responseTime: 0 // We'll calculate this properly later
            ) : nil

            let status: TransactionStatus = error != nil ? .failed : .completed
            let endTime = Date()

            let transaction = NetworkTransaction(
                request: networkRequest,
                response: networkResponse,
                status: status,
                endTime: endTime
            )

            try? await repository.save(transaction)
        }
    }
}
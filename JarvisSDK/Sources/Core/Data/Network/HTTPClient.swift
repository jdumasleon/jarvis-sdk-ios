//
//  HTTPClient.swift
//  JarvisSDK
//
//  HTTP client for executing network requests
//

import Foundation
import JarvisDomain

// MARK: - HTTP Client Protocol

/// Protocol for HTTP client abstraction
public protocol HTTPClientProtocol: Sendable {
    /// Execute an HTTP request and return the raw response
    /// - Parameter request: The HTTP request to execute
    /// - Returns: HTTPResponse containing status code, data, headers
    /// - Throws: HTTPError if the request fails
    func execute(_ request: HTTPRequest) async throws -> HTTPResponse

    /// Execute an HTTP request and decode the response to a specific type
    /// - Parameters:
    ///   - request: The HTTP request to execute
    ///   - responseType: The type to decode the response to
    /// - Returns: Decoded instance of type T
    /// - Throws: HTTPError if the request or decoding fails
    func execute<T: Codable>(_ request: HTTPRequest, responseType: T.Type) async throws -> T

    /// Execute an HTTP request without expecting a response body
    /// - Parameter request: The HTTP request to execute
    /// - Throws: HTTPError if the request fails
    func executeVoid(_ request: HTTPRequest) async throws
}

// MARK: - Default HTTP Client Implementation

/// Default implementation of HTTPClientProtocol
public final class HTTPClient: HTTPClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let enableLogging: Bool

    /// Initialize HTTPClient
    /// - Parameters:
    ///   - session: Optional URLSession to use. If nil, creates a new session with default configuration
    ///   - decoder: JSON decoder for response decoding (default: JSONDecoder())
    ///   - enableLogging: Whether to log requests/responses (default: false)
    public init(
        session: URLSession? = nil,
        decoder: JSONDecoder = JSONDecoder(),
        enableLogging: Bool = false
    ) {
        self.session = session ?? URLSession(configuration: .default)
        self.decoder = decoder
        self.enableLogging = enableLogging
    }

    public func execute(_ request: HTTPRequest) async throws -> HTTPResponse {
        let urlRequest = try buildURLRequest(from: request)

        // Log request if enabled
        if enableLogging {
            logRequest(urlRequest, body: request.body)
        }

        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw HTTPError.invalidResponse
            }

            // Log response if enabled
            if enableLogging {
                logResponse(httpResponse, data: data)
            }

            let httpResponseModel = HTTPResponse(
                data: data,
                statusCode: httpResponse.statusCode,
                headers: httpResponse.allHeaderFields.compactMap { (key, value) -> (String, String)? in
                    guard let key = key as? String else { return nil }
                    return (key, "\(value)")
                }.reduce(into: [String: String]()) { dict, pair in
                    dict[pair.0] = pair.1
                },
                url: httpResponse.url?.absoluteString
            )

            // Check for successful status codes
            guard httpResponseModel.isSuccessful else {
                let errorMessage = String(data: data, encoding: .utf8)
                throw HTTPError.statusCode(httpResponse.statusCode, errorMessage)
            }

            return httpResponseModel

        } catch let error as HTTPError {
            throw error
        } catch {
            if (error as NSError).code == NSURLErrorTimedOut {
                throw HTTPError.timeout
            }
            throw HTTPError.networkError(error)
        }
    }

    public func execute<T: Codable>(_ request: HTTPRequest, responseType: T.Type) async throws -> T {
        let response = try await execute(request)

        do {
            return try response.decode(responseType, using: decoder)
        } catch {
            throw HTTPError.decodingError(error)
        }
    }

    public func executeVoid(_ request: HTTPRequest) async throws {
        _ = try await execute(request)
    }

    // MARK: - Private Methods

    private func buildURLRequest(from request: HTTPRequest) throws -> URLRequest {
        guard let url = URL(string: request.url) else {
            throw HTTPError.invalidURL(request.url)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = request.timeout

        // Set headers
        for (key, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        // Set default headers if not provided
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if urlRequest.value(forHTTPHeaderField: "Accept") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        }

        // Set body
        urlRequest.httpBody = request.body

        return urlRequest
    }

    private func logRequest(_ request: URLRequest, body: Data?) {
        print("📤 HTTP Request")
        print("   URL: \(request.url?.absoluteString ?? "N/A")")
        print("   Method: \(request.httpMethod ?? "N/A")")
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("   Headers: \(headers)")
        }
        if let body = body, let bodyString = String(data: body, encoding: .utf8) {
            print("   Body: \(bodyString)")
        }
    }

    private func logResponse(_ response: HTTPURLResponse, data: Data) {
        print("📥 HTTP Response")
        print("   URL: \(response.url?.absoluteString ?? "N/A")")
        print("   Status: \(response.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("   Body: \(responseString)")
        }
    }
}

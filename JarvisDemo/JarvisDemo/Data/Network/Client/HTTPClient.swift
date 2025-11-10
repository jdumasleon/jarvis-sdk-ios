//
//  HTTPClient.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import Foundation
import Jarvis

// MARK: - HTTP Client Protocol

protocol HTTPClientProtocol {
    func execute(_ request: HTTPRequest) async throws -> HTTPResponse
    func execute<T: Codable>(_ request: HTTPRequest, responseType: T.Type) async throws -> T
    func executeVoid(_ request: HTTPRequest) async throws
}

// MARK: - Default HTTP Client Implementation

class HTTPClient: HTTPClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        session: URLSession? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        if let session = session {
            self.session = session
        } else {
            // Use default configuration and ensure Jarvis interceptor is registered up front.
            var configuration = URLSessionConfiguration.default
            JarvisSDK.configureURLSession(&configuration)
            self.session = URLSession(configuration: configuration)
        }
        self.decoder = decoder
    }

    func execute(_ request: HTTPRequest) async throws -> HTTPResponse {
        let urlRequest = try buildURLRequest(from: request)

        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw HTTPError.invalidResponse
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

    func execute<T: Codable>(_ request: HTTPRequest, responseType: T.Type) async throws -> T {
        let response = try await execute(request)

        do {
            return try response.decode(responseType, using: decoder)
        } catch {
            throw HTTPError.decodingError(error)
        }
    }

    func executeVoid(_ request: HTTPRequest) async throws {
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

        // Set body
        urlRequest.httpBody = request.body

        return urlRequest
    }
}

// MARK: - Mock HTTP Client (for testing)

class MockHTTPClient: HTTPClientProtocol {
    var mockResponse: HTTPResponse?
    var mockError: Error?
    var shouldSimulateDelay: Bool = true
    var simulatedDelay: TimeInterval = 1.0

    func execute(_ request: HTTPRequest) async throws -> HTTPResponse {
        if shouldSimulateDelay {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        }

        if let error = mockError {
            throw error
        }

        guard let response = mockResponse else {
            throw HTTPError.noData
        }

        return response
    }

    func execute<T: Codable>(_ request: HTTPRequest, responseType: T.Type) async throws -> T {
        let response = try await execute(request)
        return try response.decode(responseType)
    }

    func executeVoid(_ request: HTTPRequest) async throws {
        _ = try await execute(request)
    }

    // MARK: - Mock Configuration

    func setMockResponse<T: Codable>(_ object: T, statusCode: Int = 200) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(object)
        mockResponse = HTTPResponse(
            data: data,
            statusCode: statusCode,
            headers: [:],
            url: nil
        )
        mockError = nil
    }

    func setMockError(_ error: Error) {
        mockError = error
        mockResponse = nil
    }

    func reset() {
        mockResponse = nil
        mockError = nil
    }
}

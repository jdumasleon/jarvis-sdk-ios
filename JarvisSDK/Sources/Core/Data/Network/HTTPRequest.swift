//
//  HTTPRequest.swift
//  JarvisSDK
//
//  HTTP request builder with convenience methods
//

import Foundation
import JarvisDomain

/// Represents an HTTP request
public struct HTTPRequest: Sendable {
    public let url: String
    public let method: HTTPMethod
    public let headers: [String: String]
    public let body: Data?
    public let timeout: TimeInterval

    public init(
        url: String,
        method: HTTPMethod = .GET,
        headers: [String: String] = [:],
        body: Data? = nil,
        timeout: TimeInterval = 30.0
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.timeout = timeout
    }
}

// MARK: - Convenience Initializers

extension HTTPRequest {
    /// Create a GET request
    /// - Parameters:
    ///   - url: The URL string
    ///   - headers: Optional headers
    /// - Returns: HTTPRequest configured for GET
    public static func get(
        url: String,
        headers: [String: String] = [:]
    ) -> HTTPRequest {
        return HTTPRequest(url: url, method: .GET, headers: headers)
    }

    /// Create a POST request with Codable body
    /// - Parameters:
    ///   - url: The URL string
    ///   - body: The Codable body to encode
    ///   - headers: Optional headers
    ///   - encoder: JSON encoder to use (default: JSONEncoder())
    /// - Returns: HTTPRequest configured for POST
    /// - Throws: EncodingError if body encoding fails
    public static func post<T: Codable>(
        url: String,
        body: T,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder()
    ) throws -> HTTPRequest {
        let bodyData = try encoder.encode(body)
        var requestHeaders = headers
        requestHeaders["Content-Type"] = "application/json"

        return HTTPRequest(
            url: url,
            method: .POST,
            headers: requestHeaders,
            body: bodyData
        )
    }

    /// Create a PUT request with Codable body
    /// - Parameters:
    ///   - url: The URL string
    ///   - body: The Codable body to encode
    ///   - headers: Optional headers
    ///   - encoder: JSON encoder to use (default: JSONEncoder())
    /// - Returns: HTTPRequest configured for PUT
    /// - Throws: EncodingError if body encoding fails
    public static func put<T: Codable>(
        url: String,
        body: T,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder()
    ) throws -> HTTPRequest {
        let bodyData = try encoder.encode(body)
        var requestHeaders = headers
        requestHeaders["Content-Type"] = "application/json"

        return HTTPRequest(
            url: url,
            method: .PUT,
            headers: requestHeaders,
            body: bodyData
        )
    }

    /// Create a PATCH request with Codable body
    /// - Parameters:
    ///   - url: The URL string
    ///   - body: The Codable body to encode
    ///   - headers: Optional headers
    ///   - encoder: JSON encoder to use (default: JSONEncoder())
    /// - Returns: HTTPRequest configured for PATCH
    /// - Throws: EncodingError if body encoding fails
    public static func patch<T: Codable>(
        url: String,
        body: T,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder()
    ) throws -> HTTPRequest {
        let bodyData = try encoder.encode(body)
        var requestHeaders = headers
        requestHeaders["Content-Type"] = "application/json"

        return HTTPRequest(
            url: url,
            method: .PATCH,
            headers: requestHeaders,
            body: bodyData
        )
    }

    /// Create a DELETE request
    /// - Parameters:
    ///   - url: The URL string
    ///   - headers: Optional headers
    /// - Returns: HTTPRequest configured for DELETE
    public static func delete(
        url: String,
        headers: [String: String] = [:]
    ) -> HTTPRequest {
        return HTTPRequest(url: url, method: .DELETE, headers: headers)
    }
}

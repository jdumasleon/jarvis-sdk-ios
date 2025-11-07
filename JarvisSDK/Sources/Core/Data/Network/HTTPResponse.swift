//
//  HTTPResponse.swift
//  JarvisSDK
//
//  HTTP response wrapper
//

import Foundation

/// Wrapper for HTTP responses
public struct HTTPResponse: Sendable {
    public let data: Data
    public let statusCode: Int
    public let headers: [String: String]
    public let url: String?

    public var isSuccessful: Bool {
        return 200...299 ~= statusCode
    }

    public init(
        data: Data,
        statusCode: Int,
        headers: [String: String],
        url: String?
    ) {
        self.data = data
        self.statusCode = statusCode
        self.headers = headers
        self.url = url
    }
}

// MARK: - Decoding Helpers

extension HTTPResponse {
    /// Decode response data to a Codable type
    /// - Parameters:
    ///   - type: The type to decode to
    ///   - decoder: The JSON decoder to use (default: JSONDecoder())
    /// - Returns: Decoded instance of type T
    /// - Throws: DecodingError if decoding fails
    public func decode<T: Codable>(_ type: T.Type, using decoder: JSONDecoder = JSONDecoder()) throws -> T {
        return try decoder.decode(type, from: data)
    }

    /// Safely decode response data to a Codable type
    /// - Parameters:
    ///   - type: The type to decode to
    ///   - decoder: The JSON decoder to use (default: JSONDecoder())
    /// - Returns: Decoded instance of type T, or nil if decoding fails
    public func decodeIfPresent<T: Codable>(_ type: T.Type, using decoder: JSONDecoder = JSONDecoder()) -> T? {
        return try? decoder.decode(type, from: data)
    }
}

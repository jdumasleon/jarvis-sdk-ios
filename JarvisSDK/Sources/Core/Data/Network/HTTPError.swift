//
//  HTTPError.swift
//  JarvisSDK
//
//  HTTP error types for network operations
//

import Foundation

/// Errors that can occur during HTTP operations
public enum HTTPError: Error, LocalizedError, Sendable {
    case invalidURL(String)
    case noData
    case invalidResponse
    case statusCode(Int, String?)
    case decodingError(Error)
    case encodingError(Error)
    case networkError(Error)
    case timeout

    public var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .noData:
            return "No data received"
        case .invalidResponse:
            return "Invalid response received"
        case .statusCode(let code, let message):
            return "HTTP \(code): \(message ?? "Unknown error")"
        case .decodingError(let error):
            return "Decoding failed: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Encoding failed: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .timeout:
            return "Request timed out"
        }
    }
}

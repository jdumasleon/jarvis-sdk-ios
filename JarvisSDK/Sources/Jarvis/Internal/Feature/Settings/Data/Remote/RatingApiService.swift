//
//  RatingApiService.swift
//  JarvisSDK
//
//  API service for rating operations
//

import Foundation

/// API service for rating operations
protocol RatingApiService {
    /// Submit a rating to the server
    /// - Parameter rating: The rating DTO to submit
    /// - Returns: Rating submission response
    func submitRating(_ rating: RatingDto) async throws -> RatingSubmissionResponseDto
}

/// Default implementation of RatingApiService
class RatingApiServiceImpl: RatingApiService {
    private let baseURL: String
    private let session: URLSession

    init(
        baseURL: String = "https://api.jarvis-sdk.com/v1",
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    func submitRating(_ rating: RatingDto) async throws -> RatingSubmissionResponseDto {
        // Construct URL
        guard let url = URL(string: "\(baseURL)/ratings") else {
            throw RatingApiError.invalidURL
        }

        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Encode body
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(rating)

        // Perform request
        let (data, response) = try await session.data(for: request)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RatingApiError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw RatingApiError.httpError(statusCode: httpResponse.statusCode)
        }

        // Decode response
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let responseDto = try decoder.decode(RatingSubmissionResponseDto.self, from: data)

        return responseDto
    }
}

/// Errors that can occur in rating API operations
enum RatingApiError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

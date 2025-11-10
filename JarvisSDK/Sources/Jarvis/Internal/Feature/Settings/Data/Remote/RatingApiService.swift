//
//  RatingApiService.swift
//  JarvisSDK
//
//  API service for rating operations using GraphQL
//

import Foundation
import Data

/// API service for rating operations using GraphQL
protocol RatingApiService {
    /// Submit a rating to the server via GraphQL
    /// - Parameter rating: The rating to submit
    /// - Returns: Rating submission response
    func submitRating(_ rating: Rating) async throws -> RatingSubmissionResult
}

/// Default implementation of RatingApiService using HTTPClient
class RatingApiServiceImpl: RatingApiService {
    private let baseURL: String
    private let httpClient: HTTPClientProtocol

    init(
        baseURL: String = APIConfiguration.RatingAPI.baseURL,
        httpClient: HTTPClientProtocol? = nil
    ) {
        self.baseURL = baseURL
        self.httpClient = httpClient ?? HTTPClient(enableLogging: true)
    }

    func submitRating(_ rating: Rating) async throws -> RatingSubmissionResult {
        // Convert rating to GraphQL input
        let input = rating.toGraphQLInput()

        // Build GraphQL request
        let graphQLRequest = GraphQLRequest(
            query: RatingMutations.submitRating,
            variables: RatingMutationVariables(data: input)
        )

        do {
            // Create HTTP request using the new HTTPClient
            let httpRequest = try HTTPRequest.post(
                url: baseURL,
                body: graphQLRequest
            )

            // Execute request and get raw response
            let httpResponse = try await httpClient.execute(httpRequest)

            // Decode GraphQL response
            let graphQLResponse = try httpResponse.decode(
                GraphQLResponse<SubmitRatingData>.self
            )

            // Handle GraphQL errors
            if let errors = graphQLResponse.errors, !errors.isEmpty {
                let errorMessage = errors.map { $0.message }.joined(separator: ", ")
                throw RatingApiError.graphQLError(message: errorMessage)
            }

            // Extract and convert response
            guard let data = graphQLResponse.data else {
                throw RatingApiError.emptyResponse
            }

            return data.submitRating.toDomain()

        } catch let error as HTTPError {
            // Map HTTPError to RatingApiError
            throw mapHTTPError(error)
        } catch let error as RatingApiError {
            // Re-throw RatingApiError
            throw error
        } catch {
            // Wrap unexpected errors
            throw RatingApiError.networkError(error)
        }
    }

    // MARK: - Private Methods

    private func mapHTTPError(_ error: HTTPError) -> RatingApiError {
        switch error {
        case .invalidURL(let url):
            return .invalidURL(url)
        case .statusCode(let code, let message):
            return .httpError(statusCode: code, message: message)
        case .decodingError(let error):
            return .decodingError(error)
        default:
            return .networkError(error)
        }
    }
}

/// Errors that can occur in rating API operations
enum RatingApiError: LocalizedError {
    case invalidURL(String)
    case httpError(statusCode: Int, message: String?)
    case networkError(Error)
    case graphQLError(message: String)
    case emptyResponse
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid API URL: \(url)"
        case .httpError(let statusCode, let message):
            return "HTTP \(statusCode): \(message ?? "Unknown error")"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .graphQLError(let message):
            return "GraphQL error: \(message)"
        case .emptyResponse:
            return "Empty response from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

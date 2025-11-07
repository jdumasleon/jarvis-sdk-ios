//
//  GraphQLRatingDto.swift
//  JarvisSDK
//
//  GraphQL-specific data transfer objects for rating
//

import Foundation

/// Variables for the submitRating mutation
struct RatingMutationVariables: Codable {
    let data: RatingSubmissionInput
}

/// Input data for rating submission matching the GraphQL schema
struct RatingSubmissionInput: Codable {
    let stars: Int
    let description: String
    let userId: String
    let timestamp: String // ISO 8601 format
    let version: String
    let platform: String
    let sdkVersion: String
}

/// Data returned from submitRating mutation
struct SubmitRatingData: Codable {
    let submitRating: SubmitRatingResponse
}

/// Response from submitRating mutation
struct SubmitRatingResponse: Codable {
    let success: Bool
    let message: String
    let submissionId: String?
    let timestamp: String?
}

/// GraphQL mutation query string
enum RatingMutations {
    static let submitRating = """
        mutation SubmitRating($data: RatingSubmissionInput!) {
          submitRating(data: $data) {
            success
            message
            submissionId
            timestamp
          }
        }
        """
}

// MARK: - Mappers

/// Extension to convert domain Rating to GraphQL input
extension Rating {
    func toGraphQLInput() -> RatingSubmissionInput {
        // Send timestamp as milliseconds string (matching Android implementation)
        // The timestamp property is already in milliseconds, just convert to string
        let timestampString = String(timestamp)

        return RatingSubmissionInput(
            stars: stars,
            description: description,
            userId: userId ?? "anonymous",
            timestamp: timestampString,
            version: version ?? "unknown",
            platform: "ios",
            sdkVersion: version ?? "unknown"
        )
    }
}

/// Extension to convert GraphQL response to domain result
extension SubmitRatingResponse {
    func toDomain() -> RatingSubmissionResult {
        return RatingSubmissionResult(
            success: success,
            submissionId: submissionId
        )
    }
}

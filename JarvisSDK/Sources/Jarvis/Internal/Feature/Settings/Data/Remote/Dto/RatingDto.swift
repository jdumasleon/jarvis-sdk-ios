//
//  RatingDto.swift
//  JarvisSDK
//
//  Data transfer objects for rating
//

import Foundation

/// Data transfer object for rating
struct RatingDto: Codable {
    let stars: Int
    let description: String
    let userId: String?
    let timestamp: Int64
    let version: String?
    let platform: String
    let sdkVersion: String

    enum CodingKeys: String, CodingKey {
        case stars
        case description
        case userId = "user_id"
        case timestamp
        case version
        case platform
        case sdkVersion = "sdk_version"
    }

    init(
        stars: Int,
        description: String,
        userId: String?,
        timestamp: Int64,
        version: String?,
        platform: String = "ios",
        sdkVersion: String = "1.0.0"
    ) {
        self.stars = stars
        self.description = description
        self.userId = userId
        self.timestamp = timestamp
        self.version = version
        self.platform = platform
        self.sdkVersion = sdkVersion
    }
}

/// Data transfer object for rating submission response
struct RatingSubmissionResponseDto: Codable {
    let success: Bool
    let message: String
    let submissionId: String?
    let timestamp: Int64?

    enum CodingKeys: String, CodingKey {
        case success
        case message
        case submissionId = "submission_id"
        case timestamp
    }
}

// MARK: - Mappers

/// Extension to convert domain Rating to RatingDto
extension Rating {
    func toDto() -> RatingDto {
        return RatingDto(
            stars: stars,
            description: description,
            userId: userId,
            timestamp: timestamp,
            version: version
        )
    }
}

/// Extension to convert RatingSubmissionResponseDto to domain RatingSubmissionResult
extension RatingSubmissionResponseDto {
    func toDomain() -> RatingSubmissionResult {
        return RatingSubmissionResult(
            success: success,
            submissionId: submissionId
        )
    }
}

//
//  Rating.swift
//  JarvisSDK
//
//  Domain entities for rating functionality
//

import Foundation

/// Represents a user rating for the SDK
public struct Rating {
    public let stars: Int
    public let description: String
    public let userId: String?
    public let timestamp: Int64
    public let version: String?

    public init(
        stars: Int,
        description: String,
        userId: String? = nil,
        timestamp: Int64 = Int64(Date().timeIntervalSince1970 * 1000),
        version: String? = nil
    ) {
        precondition(stars >= 1 && stars <= 5, "Stars must be between 1 and 5")
        precondition(!description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Description cannot be blank")

        self.stars = stars
        self.description = description
        self.userId = userId
        self.timestamp = timestamp
        self.version = version
    }
}

/// Response from submitting a rating
public struct RatingSubmissionResult {
    public let success: Bool
    public let submissionId: String?

    public init(
        success: Bool,
        submissionId: String? = nil
    ) {
        self.success = success
        self.submissionId = submissionId
    }
}

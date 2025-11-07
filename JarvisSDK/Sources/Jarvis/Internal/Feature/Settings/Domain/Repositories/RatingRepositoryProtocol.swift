//
//  RatingRepository.swift
//  JarvisSDK
//
//  Repository interface for rating operations
//

import Foundation

/// Repository interface for rating operations
public protocol RatingRepositoryProtocol {
    /// Submit a rating for the SDK
    /// - Parameter rating: The rating to submit
    /// - Returns: Result containing submission result
    func submitRating(_ rating: Rating) async throws -> RatingSubmissionResult
}

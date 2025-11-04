//
//  SubmitRatingUseCase.swift
//  JarvisSDK
//
//  Use case for submitting SDK rating
//

import Foundation

/// Use case for submitting SDK rating
public class SubmitRatingUseCase {
    private let ratingRepository: RatingRepository

    public init(ratingRepository: RatingRepository) {
        self.ratingRepository = ratingRepository
    }

    /// Submit a rating
    /// - Parameter rating: The rating to submit
    /// - Returns: Result containing submission result
    public func execute(_ rating: Rating) async throws -> RatingSubmissionResult {
        return try await ratingRepository.submitRating(rating)
    }
}

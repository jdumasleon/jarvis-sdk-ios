//
//  RatingRepositoryImpl.swift
//  JarvisSDK
//
//  Implementation of RatingRepository
//

import Foundation

/// Implementation of RatingRepository
class RatingRepository: RatingRepositoryProtocol {
    private let ratingApiService: RatingApiService

    init(ratingApiService: RatingApiService) {
        self.ratingApiService = ratingApiService
    }

    func submitRating(_ rating: Rating) async throws -> RatingSubmissionResult {
        do {
            // GraphQL API service now handles conversion internally
            return try await ratingApiService.submitRating(rating)
        } catch {
            // Log error for debugging
            print("Error submitting rating: \(error.localizedDescription)")
            throw error
        }
    }
}

//
//  RatingRepositoryImpl.swift
//  JarvisSDK
//
//  Implementation of RatingRepository
//

import Foundation

/// Implementation of RatingRepository
class RatingRepositoryImpl: RatingRepository {
    private let ratingApiService: RatingApiService

    init(ratingApiService: RatingApiService) {
        self.ratingApiService = ratingApiService
    }

    func submitRating(_ rating: Rating) async throws -> RatingSubmissionResult {
        do {
            let ratingDto = rating.toDto()
            let responseDto = try await ratingApiService.submitRating(ratingDto)
            return responseDto.toDomain()
        } catch {
            // Log error for debugging
            print("Error submitting rating: \(error.localizedDescription)")
            throw error
        }
    }
}

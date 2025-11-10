//
//  GetDashboardMetricsUseCase.swift
//  JarvisSDK
//
//  Use case for fetching basic dashboard metrics
//

import Foundation
import Combine

/// Use case for streaming basic dashboard metrics
public final class GetDashboardMetricsUseCase {
    private let repository: DashboardRepository

    public init(repository: DashboardRepository) {
        self.repository = repository
    }

    /// Execute the use case
    /// - Returns: Publisher emitting dashboard metrics
    public func execute() -> AnyPublisher<DashboardMetrics, Error> {
        return repository.getDashboardMetrics()
    }
}

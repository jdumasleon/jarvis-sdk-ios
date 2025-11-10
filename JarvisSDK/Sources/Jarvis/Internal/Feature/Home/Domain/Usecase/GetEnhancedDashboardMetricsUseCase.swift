//
//  GetEnhancedDashboardMetricsUseCase.swift
//  JarvisSDK
//
//  Use case for fetching enhanced dashboard metrics with filtering
//

import Foundation
import Combine

/// Use case for streaming enhanced dashboard metrics with session filtering
public final class GetEnhancedDashboardMetricsUseCase {
    private let repository: DashboardRepository

    public init(repository: DashboardRepository) {
        self.repository = repository
    }

    /// Execute the use case with session filter
    /// - Parameter sessionFilter: Filter for session data
    /// - Returns: Publisher emitting enhanced dashboard metrics
    public func execute(sessionFilter: SessionFilter) -> AnyPublisher<EnhancedDashboardMetrics, Error> {
        return repository.getEnhancedDashboardMetrics(sessionFilter: sessionFilter)
    }
}

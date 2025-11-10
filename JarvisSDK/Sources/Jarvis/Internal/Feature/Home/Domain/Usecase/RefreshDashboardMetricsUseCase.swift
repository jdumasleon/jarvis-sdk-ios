//
//  RefreshDashboardMetricsUseCase.swift
//  JarvisSDK
//
//  Use case for manually refreshing dashboard metrics
//

import Foundation

/// Use case for manually refreshing all dashboard metrics
public final class RefreshDashboardMetricsUseCase {
    private let repository: DashboardRepository

    public init(repository: DashboardRepository) {
        self.repository = repository
    }

    /// Execute the use case to refresh metrics
    /// - Returns: Refreshed dashboard metrics
    public func execute() async throws -> DashboardMetrics {
        return try await repository.refreshMetrics()
    }
}

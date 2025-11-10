//
//  DashboardRepository.swift
//  JarvisSDK
//
//  Repository interface for dashboard data
//

import Foundation
import Combine

/// Repository for fetching and managing dashboard metrics
public protocol DashboardRepository {
    /// Get basic dashboard metrics
    /// - Returns: Publisher emitting dashboard metrics
    func getDashboardMetrics() -> AnyPublisher<DashboardMetrics, Error>

    /// Get enhanced dashboard metrics with session filtering
    /// - Parameter sessionFilter: Filter for session data
    /// - Returns: Publisher emitting enhanced dashboard metrics
    func getEnhancedDashboardMetrics(sessionFilter: SessionFilter) -> AnyPublisher<EnhancedDashboardMetrics, Error>

    /// Refresh all metrics (forces reload from data sources)
    /// - Returns: Refreshed dashboard metrics
    func refreshMetrics() async throws -> DashboardMetrics
}

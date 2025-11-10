//
//  DashboardCard.swift
//  JarvisSDK
//
//  Card types for the dashboard grid
//

import Foundation

/// Dashboard card types
public enum DashboardCardType: String, Codable, CaseIterable, Identifiable {
    case healthSummary = "HEALTH_SUMMARY"
    case systemPerformance = "SYSTEM_PERFORMANCE"
    case networkOverview = "NETWORK_OVERVIEW"
    case preferencesOverview = "PREFERENCES_OVERVIEW"
    case httpMethods = "HTTP_METHODS"
    case topEndpoints = "TOP_ENDPOINTS"
    case slowEndpoints = "SLOW_ENDPOINTS"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .healthSummary: return "Health Summary"
        case .systemPerformance: return "System Performance"
        case .networkOverview: return "Network Activity"
        case .preferencesOverview: return "Preferences Overview"
        case .httpMethods: return "HTTP Methods"
        case .topEndpoints: return "Top Endpoints"
        case .slowEndpoints: return "Slowest Endpoints"
        }
    }

    public var icon: String {
        switch self {
        case .healthSummary: return "heart.fill"
        case .systemPerformance: return "cpu"
        case .networkOverview: return "chart.line.uptrend.xyaxis"
        case .preferencesOverview: return "gearshape.fill"
        case .httpMethods: return "chart.pie.fill"
        case .topEndpoints: return "chart.bar.fill"
        case .slowEndpoints: return "tortoise.fill"
        }
    }

    public static func getAllCards() -> [DashboardCardType] {
        return allCases
    }
}

//
//  InspectorUiState.swift
//  Jarvis
//
//  Created by Jose Luis Dumas Leon   on 30/9/25.
//

import Foundation

/// Jarvis Home module
/// Contains the main dashboard and overview screens
public struct JarvisHome {
    public static let version = "1.0.0"
}

// MARK: - Stats Models

public struct InspectorStats {
    public let totalRequests: Int
    public let successRequests: Int
    public let errorRequests: Int
    public let averageResponseTime: TimeInterval

    public init(
        totalRequests: Int = 0,
        successRequests: Int = 0,
        errorRequests: Int = 0,
        averageResponseTime: TimeInterval = 0
    ) {
        self.totalRequests = totalRequests
        self.successRequests = successRequests
        self.errorRequests = errorRequests
        self.averageResponseTime = averageResponseTime
    }

    public var successRate: Double {
        guard totalRequests > 0 else { return 0 }
        return Double(successRequests) / Double(totalRequests)
    }
}

public struct PreferencesStats {
    public let totalChanges: Int
    public let recentChanges: Int
    public let monitoredKeys: Int

    public init(
        totalChanges: Int = 0,
        recentChanges: Int = 0,
        monitoredKeys: Int = 0
    ) {
        self.totalChanges = totalChanges
        self.recentChanges = recentChanges
        self.monitoredKeys = monitoredKeys
    }
}

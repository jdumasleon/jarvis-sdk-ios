//
//  EnhancedPreferencesMetrics.swift
//  JarvisSDK
//
//  Enhanced preferences metrics with detailed analytics and chart data
//

import Foundation

/// Enhanced preferences metrics with detailed analytics and chart data
public struct EnhancedPreferencesMetrics: Codable, Equatable {
    // Basic metrics
    public let totalPreferences: Int
    public let preferencesByType: [String: Int]
    public let mostCommonType: String?
    public let lastModified: Date?

    // Enhanced analytics for charts
    public let typeDistribution: [PreferenceTypeData]
    public let sizeDistribution: [PreferenceSizeData]
    public let activityOverTime: [TimeSeriesDataPoint]
    public let storageUsage: StorageUsageData

    // Session filtering
    public let sessionFilter: SessionFilter
    public let lastUpdated: Date

    public init(
        totalPreferences: Int,
        preferencesByType: [String: Int],
        mostCommonType: String?,
        lastModified: Date?,
        typeDistribution: [PreferenceTypeData],
        sizeDistribution: [PreferenceSizeData],
        activityOverTime: [TimeSeriesDataPoint],
        storageUsage: StorageUsageData,
        sessionFilter: SessionFilter,
        lastUpdated: Date = Date()
    ) {
        self.totalPreferences = totalPreferences
        self.preferencesByType = preferencesByType
        self.mostCommonType = mostCommonType
        self.lastModified = lastModified
        self.typeDistribution = typeDistribution
        self.sizeDistribution = sizeDistribution
        self.activityOverTime = activityOverTime
        self.storageUsage = storageUsage
        self.sessionFilter = sessionFilter
        self.lastUpdated = lastUpdated
    }
}

/// Preference type distribution data for charts
public struct PreferenceTypeData: Codable, Equatable, Identifiable {
    public let id: UUID
    public let type: String                // SharedPreferences, DataStore, etc.
    public let count: Int
    public let percentage: Float
    public let totalSize: Int64            // bytes
    public let color: String

    public init(
        id: UUID = UUID(),
        type: String,
        count: Int,
        percentage: Float,
        totalSize: Int64,
        color: String? = nil
    ) {
        self.id = id
        self.type = type
        self.count = count
        self.percentage = percentage
        self.totalSize = totalSize
        self.color = color ?? Self.getTypeColor(type)
    }

    public static func getTypeColor(_ type: String) -> String {
        switch type.lowercased() {
        case "sharedpreferences", "userdefaults": return "#4CAF50"
        case "datastore", "preferences": return "#2196F3"
        case "protodatastore", "proto": return "#9C27B0"
        case "room", "database": return "#FF9800"
        case "encrypted", "secure": return "#F44336"
        default: return "#607D8B"
        }
    }
}

/// Preference size distribution for storage analysis
public struct PreferenceSizeData: Codable, Equatable, Identifiable {
    public let id: UUID
    public let sizeRange: String           // "< 1KB", "1-10KB", etc.
    public let count: Int
    public let percentage: Float
    public let minSize: Int64
    public let maxSize: Int64

    public init(
        id: UUID = UUID(),
        sizeRange: String,
        count: Int,
        percentage: Float,
        minSize: Int64,
        maxSize: Int64
    ) {
        self.id = id
        self.sizeRange = sizeRange
        self.count = count
        self.percentage = percentage
        self.minSize = minSize
        self.maxSize = maxSize
    }
}

/// Storage usage information
public struct StorageUsageData: Codable, Equatable {
    public let totalSize: Int64            // bytes
    public let averageSize: Int64          // bytes per preference
    public let largestPreference: PreferenceInfo?
    public let storageEfficiency: Float    // 0.0-100.0 efficiency score

    public init(
        totalSize: Int64,
        averageSize: Int64,
        largestPreference: PreferenceInfo?,
        storageEfficiency: Float
    ) {
        self.totalSize = totalSize
        self.averageSize = averageSize
        self.largestPreference = largestPreference
        self.storageEfficiency = storageEfficiency
    }
}

/// Individual preference information
public struct PreferenceInfo: Codable, Equatable {
    public let key: String
    public let type: String
    public let size: Int64
    public let storageType: String
    public let lastModified: Date?

    public init(
        key: String,
        type: String,
        size: Int64,
        storageType: String,
        lastModified: Date? = nil
    ) {
        self.key = key
        self.type = type
        self.size = size
        self.storageType = storageType
        self.lastModified = lastModified
    }
}

// MARK: - Mock Data

public extension EnhancedPreferencesMetrics {
    static var mock: EnhancedPreferencesMetrics {
        let now = Date()
        return EnhancedPreferencesMetrics(
            totalPreferences: 42,
            preferencesByType: [
                "SHARED_PREFERENCES": 25,
                "DATASTORE": 12,
                "PROTO": 5
            ],
            mostCommonType: "SHARED_PREFERENCES",
            lastModified: now.addingTimeInterval(-3600),
            typeDistribution: [
                PreferenceTypeData(type: "SharedPreferences", count: 25, percentage: 59.5, totalSize: 12800),
                PreferenceTypeData(type: "DataStore", count: 12, percentage: 28.6, totalSize: 8400),
                PreferenceTypeData(type: "ProtoDataStore", count: 5, percentage: 11.9, totalSize: 3200)
            ],
            sizeDistribution: [
                PreferenceSizeData(sizeRange: "< 1KB", count: 28, percentage: 66.7, minSize: 0, maxSize: 1024),
                PreferenceSizeData(sizeRange: "1-10KB", count: 11, percentage: 26.2, minSize: 1024, maxSize: 10240),
                PreferenceSizeData(sizeRange: "10KB+", count: 3, percentage: 7.1, minSize: 10240, maxSize: Int64.max)
            ],
            activityOverTime: [
                TimeSeriesDataPoint(timestamp: now.addingTimeInterval(-86400), value: 8, label: "1d ago"),
                TimeSeriesDataPoint(timestamp: now.addingTimeInterval(-43200), value: 12, label: "12h ago"),
                TimeSeriesDataPoint(timestamp: now.addingTimeInterval(-21600), value: 15, label: "6h ago"),
                TimeSeriesDataPoint(timestamp: now.addingTimeInterval(-10800), value: 18, label: "3h ago"),
                TimeSeriesDataPoint(timestamp: now.addingTimeInterval(-3600), value: 22, label: "1h ago"),
                TimeSeriesDataPoint(timestamp: now, value: 25, label: "now")
            ],
            storageUsage: StorageUsageData(
                totalSize: 24400,
                averageSize: 580,
                largestPreference: PreferenceInfo(
                    key: "user_profile_cache",
                    type: "STRING",
                    size: 5120,
                    storageType: "SHARED_PREFERENCES",
                    lastModified: now.addingTimeInterval(-7200)
                ),
                storageEfficiency: 85.3
            ),
            sessionFilter: .lastSession,
            lastUpdated: now
        )
    }
}

//
//  PreferencesAnalyzer.swift
//  JarvisSDK
//
//  Analyzes preferences data for enhanced metrics and charts
//

import Foundation
import JarvisPreferencesDomain

/// Analyzes preferences to generate enhanced metrics and chart data
public final class PreferencesAnalyzer {

    public init() {}

    /// Analyze preferences to create enhanced metrics
    public func analyzePreferencesMetrics(
        preferences: [Preference],
        sessionFilter: SessionFilter
    ) -> EnhancedPreferencesMetrics {

        guard !preferences.isEmpty else {
            return createEmptyMetrics(sessionFilter: sessionFilter)
        }

        // Calculate basic metrics
        let totalPreferences = preferences.count

        let preferencesByType = Dictionary(grouping: preferences) { $0.type }
            .mapValues { $0.count }

        let mostCommonType = preferencesByType.max { $0.value < $1.value }?.key

        let lastModified = preferences
            .map { $0.timestamp }
            .max()

        // Generate enhanced analytics
        let typeDistribution = analyzeTypeDistribution(preferences: preferences)
        let sizeDistribution = analyzeSizeDistribution(preferences: preferences)
        let activityOverTime = generateActivityOverTime(preferences: preferences)
        let storageUsage = calculateStorageUsage(preferences: preferences)

        return EnhancedPreferencesMetrics(
            totalPreferences: totalPreferences,
            preferencesByType: preferencesByType,
            mostCommonType: mostCommonType,
            lastModified: lastModified,
            typeDistribution: typeDistribution,
            sizeDistribution: sizeDistribution,
            activityOverTime: activityOverTime,
            storageUsage: storageUsage,
            sessionFilter: sessionFilter,
            lastUpdated: Date()
        )
    }

    // MARK: - Type Distribution

    private func analyzeTypeDistribution(preferences: [Preference]) -> [PreferenceTypeData] {
        let grouped = Dictionary(grouping: preferences) { $0.source.rawValue }

        let typeData = grouped.map { source, prefs -> PreferenceTypeData in
            let count = prefs.count
            let percentage = Float(count) / Float(preferences.count) * 100.0

            let totalSize = prefs.reduce(Int64(0)) { sum, pref in
                sum + Int64(estimatePreferenceSize(pref))
            }

            return PreferenceTypeData(
                type: source,
                count: count,
                percentage: percentage,
                totalSize: totalSize
            )
        }

        return typeData.sorted { $0.count > $1.count }
    }

    // MARK: - Size Distribution

    private func analyzeSizeDistribution(preferences: [Preference]) -> [PreferenceSizeData] {
        var under1KB = 0
        var between1And10KB = 0
        var over10KB = 0

        for pref in preferences {
            let size = estimatePreferenceSize(pref)

            switch size {
            case 0..<1024: under1KB += 1
            case 1024..<10240: between1And10KB += 1
            default: over10KB += 1
            }
        }

        let total = preferences.count

        return [
            PreferenceSizeData(
                sizeRange: "< 1KB",
                count: under1KB,
                percentage: total > 0 ? Float(under1KB) / Float(total) * 100.0 : 0,
                minSize: 0,
                maxSize: 1024
            ),
            PreferenceSizeData(
                sizeRange: "1-10KB",
                count: between1And10KB,
                percentage: total > 0 ? Float(between1And10KB) / Float(total) * 100.0 : 0,
                minSize: 1024,
                maxSize: 10240
            ),
            PreferenceSizeData(
                sizeRange: "10KB+",
                count: over10KB,
                percentage: total > 0 ? Float(over10KB) / Float(total) * 100.0 : 0,
                minSize: 10240,
                maxSize: Int64.max
            )
        ]
    }

    // MARK: - Activity Over Time

    private func generateActivityOverTime(preferences: [Preference]) -> [TimeSeriesDataPoint] {
        // Generate synthetic activity data since we don't have real modification timestamps
        // In production, this would track actual preference changes over time

        let now = Date()
        let intervals = [
            (now.addingTimeInterval(-86400), "1d ago"),  // 1 day ago
            (now.addingTimeInterval(-43200), "12h ago"), // 12 hours ago
            (now.addingTimeInterval(-21600), "6h ago"),  // 6 hours ago
            (now.addingTimeInterval(-10800), "3h ago"),  // 3 hours ago
            (now.addingTimeInterval(-3600), "1h ago"),   // 1 hour ago
            (now, "now")
        ]

        // Create increasing trend
        let baseCount = Float(preferences.count) / 2.0
        return intervals.enumerated().map { index, interval in
            let value = baseCount + Float(index) * (Float(preferences.count) - baseCount) / Float(intervals.count)
            return TimeSeriesDataPoint(
                timestamp: interval.0,
                value: value,
                label: interval.1
            )
        }
    }

    // MARK: - Storage Usage

    private func calculateStorageUsage(preferences: [Preference]) -> StorageUsageData {
        let sizes = preferences.map { estimatePreferenceSize($0) }

        let totalSize = Int64(sizes.reduce(0, +))
        let averageSize = totalSize / Int64(max(preferences.count, 1))

        // Find largest preference
        let largestPref = preferences.max { pref1, pref2 in
            estimatePreferenceSize(pref1) < estimatePreferenceSize(pref2)
        }

        let largestPreference = largestPref.map { pref in
            PreferenceInfo(
                key: pref.key,
                type: pref.type,
                size: Int64(estimatePreferenceSize(pref)),
                storageType: pref.source.rawValue,
                lastModified: pref.timestamp
            )
        }

        // Calculate efficiency score
        let efficiency = calculateEfficiencyScore(preferences: preferences, sizes: sizes)

        return StorageUsageData(
            totalSize: totalSize,
            averageSize: averageSize,
            largestPreference: largestPreference,
            storageEfficiency: efficiency
        )
    }

    private func calculateEfficiencyScore(preferences: [Preference], sizes: [Int]) -> Float {
        guard !sizes.isEmpty else { return 100.0 }

        // Calculate variance in sizes (lower variance = more efficient)
        let avgSize = Double(sizes.reduce(0, +)) / Double(sizes.count)
        let variance = sizes.reduce(0.0) { sum, size in
            let diff = Double(size) - avgSize
            return sum + (diff * diff)
        } / Double(sizes.count)

        let normalizedVariance = min(variance / 10000.0, 1.0) // Normalize to 0-1
        let varianceScore = (1.0 - normalizedVariance) * 50.0 // 0-50 points

        // Calculate redundancy score (fewer duplicate key patterns = more efficient)
        let uniqueKeyPatterns = Set(preferences.map { extractKeyPattern($0.key) }).count
        let redundancy = 1.0 - Double(uniqueKeyPatterns) / Double(preferences.count)
        let redundancyScore = (1.0 - redundancy) * 50.0 // 0-50 points

        return Float(varianceScore + redundancyScore)
    }

    // MARK: - Helper Functions

    private func estimatePreferenceSize(_ preference: Preference) -> Int {
        // Estimate size: key + value + metadata
        let keySize = preference.key.utf8.count

        let valueSize: Int
        let valueString = String(describing: preference.value)
        valueSize = valueString.utf8.count

        let metadataSize = 50 // Approximate overhead for type, source, etc.

        return keySize + valueSize + metadataSize
    }

    private func extractKeyPattern(_ key: String) -> String {
        // Extract pattern by removing numbers and specific values
        return key.replacingOccurrences(
            of: "\\d+",
            with: "",
            options: .regularExpression
        )
    }

    private func createEmptyMetrics(sessionFilter: SessionFilter) -> EnhancedPreferencesMetrics {
        return EnhancedPreferencesMetrics(
            totalPreferences: 0,
            preferencesByType: [:],
            mostCommonType: nil,
            lastModified: nil,
            typeDistribution: [],
            sizeDistribution: [],
            activityOverTime: [],
            storageUsage: StorageUsageData(
                totalSize: 0,
                averageSize: 0,
                largestPreference: nil,
                storageEfficiency: 100.0
            ),
            sessionFilter: sessionFilter,
            lastUpdated: Date()
        )
    }
}

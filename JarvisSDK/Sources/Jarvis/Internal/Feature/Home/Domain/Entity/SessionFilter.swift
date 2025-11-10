//
//  SessionFilter.swift
//  JarvisSDK
//
//  Session filter options for dashboard data
//

import Foundation

/// Session filter options for dashboard data
public enum SessionFilter: String, Codable, CaseIterable {
    case last24Hours = "LAST 24H"      // Last 24 hours data only
    case lastSession = "LAST SESSION"  // Current app session only
    

    public var displayName: String {
        switch self {
        case .lastSession: return "Current Session"
        case .last24Hours: return "Last 24 Hours"
        }
    }

    public var icon: String {
        switch self {
        case .lastSession: return "clock"
        case .last24Hours: return "calendar"
        }
    }

    public var description: String {
        switch self {
        case .lastSession: return "Data from the last hour"
        case .last24Hours: return "Data from the last 24 hours"
        }
    }
}

/// Session info for filtering dashboard metrics
public struct SessionInfo: Codable, Equatable {
    public let sessionId: String
    public let startTime: Date
    public let endTime: Date?
    public var isCurrentSession: Bool { endTime == nil }

    public init(sessionId: String, startTime: Date, endTime: Date? = nil) {
        self.sessionId = sessionId
        self.startTime = startTime
        self.endTime = endTime
    }
}

//
//  HomeUiState.swift
//  JarvisSDK
//
//  Home screen UI state and events
//

import Foundation
import Common

/// Home screen UI state
public struct HomeUiState {
    public let enhancedMetrics: EnhancedDashboardMetrics?
    public let selectedSessionFilter: SessionFilter
    public let cardOrder: [DashboardCardType]
    public let isDragging: Bool
    public let dragFromIndex: Int?
    public let dragToIndex: Int?
    public let isLoading: Bool
    public let isRefreshing: Bool
    public let isHeaderContentVisible: Bool
    public let error: Error?
    public let lastUpdated: Date

    public init(
        enhancedMetrics: EnhancedDashboardMetrics? = nil,
        selectedSessionFilter: SessionFilter = .lastSession,
        cardOrder: [DashboardCardType] = DashboardCardType.getAllCards(),
        isDragging: Bool = false,
        dragFromIndex: Int? = nil,
        dragToIndex: Int? = nil,
        isLoading: Bool = false,
        isRefreshing: Bool = false,
        isHeaderContentVisible: Bool = true,
        error: Error? = nil,
        lastUpdated: Date = Date()
    ) {
        self.enhancedMetrics = enhancedMetrics
        self.selectedSessionFilter = selectedSessionFilter
        self.cardOrder = cardOrder
        self.isDragging = isDragging
        self.dragFromIndex = dragFromIndex
        self.dragToIndex = dragToIndex
        self.isLoading = isLoading
        self.isRefreshing = isRefreshing
        self.isHeaderContentVisible = isHeaderContentVisible
        self.error = error
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Home Events

/// Events that can occur in the home screen
public enum HomeEvent {
    case refreshDashboard
    case changeSessionFilter(SessionFilter)
    case moveCard(fromIndex: Int, toIndex: Int)
    case startDrag(index: Int)
    case updateDragPosition(fromIndex: Int, toIndex: Int)
    case endDrag
    case dismissHeaderContent
}

// MARK: - Mock Data

public extension HomeUiState {
    static var mock: HomeUiState {
        HomeUiState(
            enhancedMetrics: .mock,
            selectedSessionFilter: .lastSession,
            cardOrder: DashboardCardType.getAllCards(),
            isDragging: false,
            isLoading: false,
            isRefreshing: false,
            isHeaderContentVisible: true,
            error: nil,
            lastUpdated: Date()
        )
    }
}

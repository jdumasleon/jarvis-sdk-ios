//
//  HomeViewModel.swift
//  JarvisSDK
//
//  Home screen view model
//

import Foundation
import Combine
import Common

/// Home screen view model
@MainActor
public final class HomeViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published public private(set) var uiState: HomeUiState = HomeUiState()

    // MARK: - Dependencies

    private let getEnhancedMetricsUseCase: GetEnhancedDashboardMetricsUseCase
    private let refreshMetricsUseCase: RefreshDashboardMetricsUseCase

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(
        getEnhancedMetricsUseCase: GetEnhancedDashboardMetricsUseCase,
        refreshMetricsUseCase: RefreshDashboardMetricsUseCase
    ) {
        self.getEnhancedMetricsUseCase = getEnhancedMetricsUseCase
        self.refreshMetricsUseCase = refreshMetricsUseCase

        // Load initial data
        loadDashboardData(filter: .lastSession, showLoading: true)
    }

    // MARK: - Event Handling

    public func onEvent(_ event: HomeEvent) {
        switch event {
        case .refreshDashboard:
            refreshDashboard()

        case .changeSessionFilter(let filter):
            changeSessionFilter(filter)

        case .moveCard(let fromIndex, let toIndex):
            moveCard(from: fromIndex, to: toIndex)

        case .startDrag(let index):
            startDrag(at: index)

        case .updateDragPosition(let fromIndex, let toIndex):
            updateDragPosition(from: fromIndex, to: toIndex)

        case .endDrag:
            endDrag()

        case .dismissHeaderContent:
            dismissHeaderContent()
        }
    }

    // MARK: - Data Loading

    private func loadDashboardData(filter: SessionFilter, showLoading: Bool) {
        // Update loading state
        uiState = HomeUiState(
            enhancedMetrics: showLoading ? nil : uiState.enhancedMetrics,
            selectedSessionFilter: filter,
            cardOrder: uiState.cardOrder,
            isDragging: uiState.isDragging,
            dragFromIndex: uiState.dragFromIndex,
            dragToIndex: uiState.dragToIndex,
            isLoading: showLoading,
            isRefreshing: !showLoading,
            isHeaderContentVisible: uiState.isHeaderContentVisible,
            error: nil,
            lastUpdated: uiState.lastUpdated
        )

        // Fetch metrics
        getEnhancedMetricsUseCase.execute(sessionFilter: filter)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }

                    if case .failure(let error) = completion {
                        self.handleError(error, filter: filter)
                    }
                },
                receiveValue: { [weak self] metrics in
                    guard let self = self else { return }
                    self.handleMetricsLoaded(metrics, filter: filter)
                }
            )
            .store(in: &cancellables)
    }

    private func handleMetricsLoaded(_ metrics: EnhancedDashboardMetrics, filter: SessionFilter) {
        uiState = HomeUiState(
            enhancedMetrics: metrics,
            selectedSessionFilter: filter,
            cardOrder: uiState.cardOrder,
            isDragging: false,
            dragFromIndex: nil,
            dragToIndex: nil,
            isLoading: false,
            isRefreshing: false,
            isHeaderContentVisible: uiState.isHeaderContentVisible,
            error: nil,
            lastUpdated: Date()
        )
    }

    private func handleError(_ error: Error, filter: SessionFilter) {
        uiState = HomeUiState(
            enhancedMetrics: uiState.enhancedMetrics, // Preserve existing data
            selectedSessionFilter: filter,
            cardOrder: uiState.cardOrder,
            isDragging: false,
            dragFromIndex: nil,
            dragToIndex: nil,
            isLoading: false,
            isRefreshing: false,
            isHeaderContentVisible: uiState.isHeaderContentVisible,
            error: error,
            lastUpdated: uiState.lastUpdated
        )
    }

    // MARK: - User Actions

    private func refreshDashboard() {
        loadDashboardData(filter: uiState.selectedSessionFilter, showLoading: false)
    }

    private func changeSessionFilter(_ filter: SessionFilter) {
        guard filter != uiState.selectedSessionFilter else { return }
        loadDashboardData(filter: filter, showLoading: true)
    }

    private func moveCard(from fromIndex: Int, to toIndex: Int) {
        var newOrder = uiState.cardOrder
        let card = newOrder.remove(at: fromIndex)
        newOrder.insert(card, at: toIndex)

        uiState = HomeUiState(
            enhancedMetrics: uiState.enhancedMetrics,
            selectedSessionFilter: uiState.selectedSessionFilter,
            cardOrder: newOrder,
            isDragging: false,
            dragFromIndex: nil,
            dragToIndex: nil,
            isLoading: uiState.isLoading,
            isRefreshing: uiState.isRefreshing,
            isHeaderContentVisible: uiState.isHeaderContentVisible,
            error: uiState.error,
            lastUpdated: uiState.lastUpdated
        )
    }

    private func startDrag(at index: Int) {
        uiState = HomeUiState(
            enhancedMetrics: uiState.enhancedMetrics,
            selectedSessionFilter: uiState.selectedSessionFilter,
            cardOrder: uiState.cardOrder,
            isDragging: true,
            dragFromIndex: index,
            dragToIndex: nil,
            isLoading: uiState.isLoading,
            isRefreshing: uiState.isRefreshing,
            isHeaderContentVisible: uiState.isHeaderContentVisible,
            error: uiState.error,
            lastUpdated: uiState.lastUpdated
        )
    }

    private func updateDragPosition(from fromIndex: Int, to toIndex: Int) {
        uiState = HomeUiState(
            enhancedMetrics: uiState.enhancedMetrics,
            selectedSessionFilter: uiState.selectedSessionFilter,
            cardOrder: uiState.cardOrder,
            isDragging: true,
            dragFromIndex: fromIndex,
            dragToIndex: toIndex,
            isLoading: uiState.isLoading,
            isRefreshing: uiState.isRefreshing,
            isHeaderContentVisible: uiState.isHeaderContentVisible,
            error: uiState.error,
            lastUpdated: uiState.lastUpdated
        )
    }

    private func endDrag() {
        if let fromIndex = uiState.dragFromIndex,
           let toIndex = uiState.dragToIndex {
            moveCard(from: fromIndex, to: toIndex)
        } else {
            uiState = HomeUiState(
                enhancedMetrics: uiState.enhancedMetrics,
                selectedSessionFilter: uiState.selectedSessionFilter,
                cardOrder: uiState.cardOrder,
                isDragging: false,
                dragFromIndex: nil,
                dragToIndex: nil,
                isLoading: uiState.isLoading,
                isRefreshing: uiState.isRefreshing,
                isHeaderContentVisible: uiState.isHeaderContentVisible,
                error: uiState.error,
                lastUpdated: uiState.lastUpdated
            )
        }
    }

    private func dismissHeaderContent() {
        uiState = HomeUiState(
            enhancedMetrics: uiState.enhancedMetrics,
            selectedSessionFilter: uiState.selectedSessionFilter,
            cardOrder: uiState.cardOrder,
            isDragging: uiState.isDragging,
            dragFromIndex: uiState.dragFromIndex,
            dragToIndex: uiState.dragToIndex,
            isLoading: uiState.isLoading,
            isRefreshing: uiState.isRefreshing,
            isHeaderContentVisible: false,
            error: uiState.error,
            lastUpdated: uiState.lastUpdated
        )
    }
}

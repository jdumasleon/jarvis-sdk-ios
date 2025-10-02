//
//  InspectorViewModel.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import SwiftUI
import Combine

struct InspectorUiData {
    let apiCalls: [ApiCallResult]
    let filteredApiCalls: [ApiCallResult]
    let searchQuery: String
    let selectedMethod: String?
    let isRefreshing: Bool
    let totalCalls: Int
    let successfulCalls: Int
    let failedCalls: Int

    static let empty = InspectorUiData(
        apiCalls: [],
        filteredApiCalls: [],
        searchQuery: "",
        selectedMethod: nil,
        isRefreshing: false,
        totalCalls: 0,
        successfulCalls: 0,
        failedCalls: 0
    )
}

@MainActor
class InspectorViewModel: ObservableObject {
    @Published var uiState: ResourceState<InspectorUiData> = .idle

    private let performApiCallsUseCase: PerformApiCallsUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    init(performApiCallsUseCase: PerformApiCallsUseCaseProtocol = PerformApiCallsUseCase()) {
        self.performApiCallsUseCase = performApiCallsUseCase
        loadInitialData()
    }

    private func loadInitialData() {
        uiState = .loading

        Task {
            do {
                let apiCalls = await performApiCallsUseCase.performInitialApiCalls(numberOfCalls: 15)
                let uiData = createUiData(
                    apiCalls: apiCalls,
                    searchQuery: "",
                    selectedMethod: nil,
                    isRefreshing: false
                )
                uiState = .success(uiData)
            } catch {
                uiState = .error(error)
            }
        }
    }

    private func createUiData(
        apiCalls: [ApiCallResult],
        searchQuery: String,
        selectedMethod: String?,
        isRefreshing: Bool
    ) -> InspectorUiData {
        let filteredApiCalls = filterApiCalls(apiCalls, searchQuery: searchQuery, selectedMethod: selectedMethod)
        let successfulCalls = apiCalls.filter { $0.isSuccess }.count
        let failedCalls = apiCalls.count - successfulCalls

        return InspectorUiData(
            apiCalls: apiCalls,
            filteredApiCalls: filteredApiCalls,
            searchQuery: searchQuery,
            selectedMethod: selectedMethod,
            isRefreshing: isRefreshing,
            totalCalls: apiCalls.count,
            successfulCalls: successfulCalls,
            failedCalls: failedCalls
        )
    }

    private func filterApiCalls(
        _ apiCalls: [ApiCallResult],
        searchQuery: String,
        selectedMethod: String?
    ) -> [ApiCallResult] {
        var filtered = apiCalls

        // Filter by search query
        if !searchQuery.isEmpty {
            filtered = filtered.filter {
                $0.url.localizedCaseInsensitiveContains(searchQuery) ||
                $0.method.localizedCaseInsensitiveContains(searchQuery) ||
                $0.host.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        // Filter by method
        if let selectedMethod = selectedMethod, !selectedMethod.isEmpty {
            filtered = filtered.filter { $0.method == selectedMethod }
        }

        return filtered.sorted { $0.startTime > $1.startTime }
    }

    // MARK: - Events

    func onEvent(_ event: InspectorEvent) {
        switch event {
        case .RefreshApiCalls:
            refreshApiCalls()
        case .PerformRandomApiCall:
            performRandomApiCall()
        case .SearchQueryChanged(let query):
            updateSearchQuery(query)
        case .MethodFilterChanged(let method):
            updateMethodFilter(method)
        case .ClearFilters:
            clearFilters()
        }
    }

    private func refreshApiCalls() {
        guard case .success(let currentData) = uiState else { return }

        let refreshingData = InspectorUiData(
            apiCalls: currentData.apiCalls,
            filteredApiCalls: currentData.filteredApiCalls,
            searchQuery: currentData.searchQuery,
            selectedMethod: currentData.selectedMethod,
            isRefreshing: true,
            totalCalls: currentData.totalCalls,
            successfulCalls: currentData.successfulCalls,
            failedCalls: currentData.failedCalls
        )
        uiState = .success(refreshingData)

        Task {
            do {
                let newApiCalls = await performApiCallsUseCase.performRefreshApiCalls(numberOfCalls: 5)
                let allApiCalls = newApiCalls + currentData.apiCalls

                let updatedData = createUiData(
                    apiCalls: allApiCalls,
                    searchQuery: currentData.searchQuery,
                    selectedMethod: currentData.selectedMethod,
                    isRefreshing: false
                )
                uiState = .success(updatedData)
            } catch {
                uiState = .error(error)
            }
        }
    }

    private func performRandomApiCall() {
        guard case .success(let currentData) = uiState else { return }

        Task {
            do {
                let newApiCall = await performApiCallsUseCase.performRandomApiCall()
                let allApiCalls = [newApiCall] + currentData.apiCalls

                let updatedData = createUiData(
                    apiCalls: allApiCalls,
                    searchQuery: currentData.searchQuery,
                    selectedMethod: currentData.selectedMethod,
                    isRefreshing: false
                )
                uiState = .success(updatedData)
            } catch {
                uiState = .error(error)
            }
        }
    }

    private func updateSearchQuery(_ query: String) {
        guard case .success(let currentData) = uiState else { return }

        let updatedData = createUiData(
            apiCalls: currentData.apiCalls,
            searchQuery: query,
            selectedMethod: currentData.selectedMethod,
            isRefreshing: false
        )
        uiState = .success(updatedData)
    }

    private func updateMethodFilter(_ method: String?) {
        guard case .success(let currentData) = uiState else { return }

        let updatedData = createUiData(
            apiCalls: currentData.apiCalls,
            searchQuery: currentData.searchQuery,
            selectedMethod: method,
            isRefreshing: false
        )
        uiState = .success(updatedData)
    }

    private func clearFilters() {
        guard case .success(let currentData) = uiState else { return }

        let updatedData = createUiData(
            apiCalls: currentData.apiCalls,
            searchQuery: "",
            selectedMethod: nil,
            isRefreshing: false
        )
        uiState = .success(updatedData)
    }
}

enum InspectorEvent {
    case RefreshApiCalls
    case PerformRandomApiCall
    case SearchQueryChanged(String)
    case MethodFilterChanged(String?)
    case ClearFilters
}
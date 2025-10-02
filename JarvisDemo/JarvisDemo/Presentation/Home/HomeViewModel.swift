//
//  HomeViewModel.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import SwiftUI
import Combine
import Jarvis

enum ResourceState<T> {
    case idle
    case loading
    case success(T)
    case error(Error)
}

struct HomeUiData {
    let isJarvisActive: Bool
    let jarvisConfiguration: JarvisConfig
    let recentApiCalls: [ApiCallResult]
    let isRefreshing: Bool

    static let empty = HomeUiData(
        isJarvisActive: false,
        jarvisConfiguration: JarvisConfig(),
        recentApiCalls: [],
        isRefreshing: false
    )
}

@MainActor
class HomeViewModel: ObservableObject {
    @Published var uiState: ResourceState<HomeUiData> = .idle

    private let manageJarvisModeUseCase: ManageJarvisModeUseCaseProtocol
    private let refreshDataUseCase: RefreshDataUseCaseProtocol
    private let performApiCallsUseCase: PerformApiCallsUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        manageJarvisModeUseCase: ManageJarvisModeUseCaseProtocol = ManageJarvisModeUseCase(),
        refreshDataUseCase: RefreshDataUseCaseProtocol = RefreshDataUseCase(),
        performApiCallsUseCase: PerformApiCallsUseCaseProtocol = PerformApiCallsUseCase()
    ) {
        self.manageJarvisModeUseCase = manageJarvisModeUseCase
        self.refreshDataUseCase = refreshDataUseCase
        self.performApiCallsUseCase = performApiCallsUseCase

        setupObservers()
        loadInitialData()
    }

    private func setupObservers() {
        // Observe Jarvis SDK state changes
        JarvisSDK.shared.$isActive
            .sink { [weak self] _ in
                self?.updateUiState()
            }
            .store(in: &cancellables)
    }

    private func loadInitialData() {
        uiState = .loading
        updateUiState()
    }

    private func updateUiState() {
        let currentData = getCurrentUiData()
        uiState = .success(currentData)
    }

    private func getCurrentUiData() -> HomeUiData {
        switch uiState {
        case .success(let data):
            return HomeUiData(
                isJarvisActive: manageJarvisModeUseCase.isJarvisActive(),
                jarvisConfiguration: manageJarvisModeUseCase.getJarvisConfiguration(),
                recentApiCalls: data.recentApiCalls,
                isRefreshing: data.isRefreshing
            )
        default:
            return HomeUiData(
                isJarvisActive: manageJarvisModeUseCase.isJarvisActive(),
                jarvisConfiguration: manageJarvisModeUseCase.getJarvisConfiguration(),
                recentApiCalls: [],
                isRefreshing: false
            )
        }
    }

    // MARK: - Events

    func onEvent(_ event: HomeEvent) {
        switch event {
        case .ToggleJarvisMode:
            toggleJarvisMode()
        case .RefreshData:
            refreshData()
        case .PerformTestApiCall:
            performTestApiCall()
        case .ClearData:
            clearData()
        case .ShowJarvisOverlay:
            showJarvisOverlay()
        }
    }

    private func toggleJarvisMode() {
        _ = manageJarvisModeUseCase.toggleJarvis()
        updateUiState()
    }

    private func refreshData() {
        Task {
            if case .success(let currentData) = uiState {
                let refreshingData = HomeUiData(
                    isJarvisActive: currentData.isJarvisActive,
                    jarvisConfiguration: currentData.jarvisConfiguration,
                    recentApiCalls: currentData.recentApiCalls,
                    isRefreshing: true
                )
                uiState = .success(refreshingData)
            }

            do {
                let apiCalls = await refreshDataUseCase.refreshData()

                if case .success(let currentData) = uiState {
                    let updatedData = HomeUiData(
                        isJarvisActive: currentData.isJarvisActive,
                        jarvisConfiguration: currentData.jarvisConfiguration,
                        recentApiCalls: apiCalls,
                        isRefreshing: false
                    )
                    uiState = .success(updatedData)
                }
            } catch {
                uiState = .error(error)
            }
        }
    }

    private func performTestApiCall() {
        Task {
            do {
                let apiCall = await performApiCallsUseCase.performRandomApiCall()

                if case .success(let currentData) = uiState {
                    let newApiCalls = [apiCall] + currentData.recentApiCalls
                    let updatedData = HomeUiData(
                        isJarvisActive: currentData.isJarvisActive,
                        jarvisConfiguration: currentData.jarvisConfiguration,
                        recentApiCalls: Array(newApiCalls.prefix(10)), // Keep only last 10
                        isRefreshing: false
                    )
                    uiState = .success(updatedData)
                }
            } catch {
                uiState = .error(error)
            }
        }
    }

    private func clearData() {
        if case .success(let currentData) = uiState {
            let clearedData = HomeUiData(
                isJarvisActive: currentData.isJarvisActive,
                jarvisConfiguration: currentData.jarvisConfiguration,
                recentApiCalls: [],
                isRefreshing: false
            )
            uiState = .success(clearedData)
        }
    }

    private func showJarvisOverlay() {
        JarvisSDK.shared.showOverlay()
    }
}

enum HomeEvent {
    case ToggleJarvisMode
    case RefreshData
    case PerformTestApiCall
    case ClearData
    case ShowJarvisOverlay
}
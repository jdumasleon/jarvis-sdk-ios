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
    let lastRefreshDate: Date?
    let appVersion: String

    static let empty = HomeUiData(
        isJarvisActive: false,
        jarvisConfiguration: JarvisConfig(),
        recentApiCalls: [],
        isRefreshing: false,
        lastRefreshDate: nil,
        appVersion: ""
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

        loadInitialData()
        observeJarvisState()
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
        let appVersion = getAppVersion()

        switch uiState {
        case .success(let data):
            return HomeUiData(
                isJarvisActive: JarvisSDK.shared.isActive,
                jarvisConfiguration: manageJarvisModeUseCase.getJarvisConfiguration(),
                recentApiCalls: data.recentApiCalls,
                isRefreshing: data.isRefreshing,
                lastRefreshDate: data.lastRefreshDate,
                appVersion: appVersion
            )
        default:
            return HomeUiData(
                isJarvisActive: JarvisSDK.shared.isActive,
                jarvisConfiguration: manageJarvisModeUseCase.getJarvisConfiguration(),
                recentApiCalls: [],
                isRefreshing: false,
                lastRefreshDate: nil,
                appVersion: appVersion
            )
        }
    }

    private func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "v\(version) (\(build))"
    }

    private func observeJarvisState() {
        JarvisSDK.shared.$isActive
            .sink { [weak self] _ in
                self?.updateUiState()
            }
            .store(in: &cancellables)
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
        if JarvisSDK.shared.isActive {
            manageJarvisModeUseCase.deactivateJarvis()
        } else {
            manageJarvisModeUseCase.activateJarvis()
        }
        updateUiState()
    }

    private func refreshData() {
        Task {
            do {
                let apiCalls = await refreshDataUseCase.refreshData()

                if case .success(let currentData) = uiState {
                    let updatedData = HomeUiData(
                        isJarvisActive: currentData.isJarvisActive,
                        jarvisConfiguration: currentData.jarvisConfiguration,
                        recentApiCalls: apiCalls,
                        isRefreshing: false,
                        lastRefreshDate: Date(),
                        appVersion: currentData.appVersion
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
                        isRefreshing: false,
                        lastRefreshDate: currentData.lastRefreshDate,
                        appVersion: currentData.appVersion
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
                isRefreshing: false,
                lastRefreshDate: currentData.lastRefreshDate,
                appVersion: currentData.appVersion
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

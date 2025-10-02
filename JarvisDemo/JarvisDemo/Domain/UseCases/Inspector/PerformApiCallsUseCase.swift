//
//  PerformApiCallsUseCase.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import Foundation

protocol PerformApiCallsUseCaseProtocol {
    func performRandomApiCall() async -> ApiCallResult
    func performInitialApiCalls(numberOfCalls: Int) async -> [ApiCallResult]
    func performRefreshApiCalls(numberOfCalls: Int) async -> [ApiCallResult]
}

class PerformApiCallsUseCase: PerformApiCallsUseCaseProtocol {
    private let repository: DemoApiRepositoryProtocol

    init(repository: DemoApiRepositoryProtocol = AppConfiguration.shared.apiServiceFactory.createDemoApiRepository()) {
        self.repository = repository
    }

    func performRandomApiCall() async -> ApiCallResult {
        return await repository.performRandomApiCall()
    }

    func performInitialApiCalls(numberOfCalls: Int = Int.random(in: 10...20)) async -> [ApiCallResult] {
        return await repository.performInitialApiCalls(numberOfCalls: numberOfCalls)
    }

    func performRefreshApiCalls(numberOfCalls: Int = 3) async -> [ApiCallResult] {
        return await repository.performRefreshApiCalls(numberOfCalls: numberOfCalls)
    }
}
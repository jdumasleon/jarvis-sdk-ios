//
//  RefreshDataUseCase.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import Foundation

protocol RefreshDataUseCaseProtocol {
    func refreshData() async -> [ApiCallResult]
}

class RefreshDataUseCase: RefreshDataUseCaseProtocol {
    private let repository: DemoApiRepositoryProtocol

    init(repository: DemoApiRepositoryProtocol = AppConfiguration.shared.apiServiceFactory.createDemoApiRepository()) {
        self.repository = repository
    }

    func refreshData() async -> [ApiCallResult] {
        return await repository.performRefreshApiCalls(numberOfCalls: 3)
    }
}
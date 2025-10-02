//
//  NetworkConfiguration.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import Foundation

// MARK: - Network Configuration

struct NetworkConfiguration {
    let timeout: TimeInterval
    let retryCount: Int
    let enableLogging: Bool
    let simulateNetworkDelay: Bool
    let networkDelayRange: ClosedRange<Double>

    static let `default` = NetworkConfiguration(
        timeout: 30.0,
        retryCount: 3,
        enableLogging: true,
        simulateNetworkDelay: true,
        networkDelayRange: 0.2...1.5
    )

    static let testing = NetworkConfiguration(
        timeout: 5.0,
        retryCount: 1,
        enableLogging: false,
        simulateNetworkDelay: false,
        networkDelayRange: 0.0...0.1
    )
}

// MARK: - HTTP Client Factory

class HTTPClientFactory {
    static func createDefault() -> HTTPClientProtocol {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = NetworkConfiguration.default.timeout
        configuration.timeoutIntervalForResource = NetworkConfiguration.default.timeout * 2

        let session = URLSession(configuration: configuration)
        return HTTPClient(session: session)
    }

    static func createForTesting() -> HTTPClientProtocol {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = NetworkConfiguration.testing.timeout
        configuration.timeoutIntervalForResource = NetworkConfiguration.testing.timeout * 2

        let session = URLSession(configuration: configuration)
        return HTTPClient(session: session)
    }

    static func createMock() -> MockHTTPClient {
        return MockHTTPClient()
    }
}

// MARK: - API Service Factory

class APIServiceFactory {
    private let httpClient: HTTPClientProtocol

    init(httpClient: HTTPClientProtocol = HTTPClientFactory.createDefault()) {
        self.httpClient = httpClient
    }

    func createFakeStoreApiService() -> FakeStoreApiService {
        return FakeStoreApiServiceImpl(httpClient: httpClient)
    }

    func createRestfulApiService() -> RestfulApiService {
        return RestfulApiServiceImpl(httpClient: httpClient)
    }

    func createDemoApiRepository() -> DemoApiRepositoryProtocol {
        return DemoApiRepository(
            fakeStoreApi: createFakeStoreApiService(),
            restfulApi: createRestfulApiService()
        )
    }
}

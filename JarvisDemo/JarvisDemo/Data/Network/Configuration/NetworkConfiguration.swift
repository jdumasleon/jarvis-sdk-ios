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
        // IMPORTANT: Don't pass a session here!
        // Let HTTPClient create its own session so it can pick up
        // registered URLProtocols (like Jarvis's URLSessionInterceptor)
        return HTTPClient()
    }

    static func createForTesting() -> HTTPClientProtocol {
        // IMPORTANT: Don't pass a session here!
        // Let HTTPClient create its own session so it can pick up
        // registered URLProtocols (like Jarvis's URLSessionInterceptor)
        return HTTPClient()
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

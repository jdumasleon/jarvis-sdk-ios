//
//  Environment.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

// MARK: - Environment Configuration

enum AppEnvironment {
    case development
    case staging
    case production

    var baseURLs: (fakeStore: String, restful: String) {
        switch self {
        case .development:
            return (
                fakeStore: "https://fakestoreapi.com",
                restful: "https://api.restful-api.dev"
            )
        case .staging:
            return (
                fakeStore: "https://staging-fakestoreapi.com",
                restful: "https://staging-api.restful-api.dev"
            )
        case .production:
            return (
                fakeStore: "https://fakestoreapi.com",
                restful: "https://api.restful-api.dev"
            )
        }
    }

    var networkConfiguration: NetworkConfiguration {
        switch self {
        case .development:
            return .default
        case .staging:
            return NetworkConfiguration(
                timeout: 20.0,
                retryCount: 2,
                enableLogging: true,
                simulateNetworkDelay: true,
                networkDelayRange: 0.1...1.0
            )
        case .production:
            return NetworkConfiguration(
                timeout: 15.0,
                retryCount: 3,
                enableLogging: false,
                simulateNetworkDelay: false,
                networkDelayRange: 0.0...0.0
            )
        }
    }
}

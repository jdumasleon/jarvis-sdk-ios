//
//  AppConfiguration.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

// MARK: - App Configuration

class AppConfiguration {
    static let shared = AppConfiguration()

    let currentEnvironment: AppEnvironment
    let networkConfiguration: NetworkConfiguration

    private init() {
        #if DEBUG
        self.currentEnvironment = .development
        #else
        self.currentEnvironment = .production
        #endif

        self.networkConfiguration = currentEnvironment.networkConfiguration
    }

    lazy var apiServiceFactory: APIServiceFactory = {
        let httpClient = HTTPClientFactory.createDefault()
        return APIServiceFactory(httpClient: httpClient)
    }()
}

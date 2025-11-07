//
//  APIConfiguration.swift
//  JarvisSDK
//
//  Centralized API configuration
//

import Foundation

/// Centralized configuration for API endpoints
enum APIConfiguration {

    /// Rating API configuration
    enum RatingAPI {
        /// Base URL for the Rating GraphQL API
        static let baseURL = "https://porfolio-keystone-server-production.up.railway.app/api/graphql"

        /// Timeout interval for network requests (in seconds)
        static let timeoutInterval: TimeInterval = 30.0
    }

    // Add other API configurations here as needed
    // enum AnotherAPI {
    //     static let baseURL = "https://..."
    // }
}

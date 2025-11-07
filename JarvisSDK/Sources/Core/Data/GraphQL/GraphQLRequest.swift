//
//  GraphQLRequest.swift
//  JarvisSDK
//
//  Generic GraphQL request and response models
//

import Foundation

/// Generic GraphQL request wrapper
public struct GraphQLRequest<Variables: Codable>: Codable {
    public let query: String
    public let variables: Variables

    public init(query: String, variables: Variables) {
        self.query = query
        self.variables = variables
    }
}

/// Generic GraphQL response wrapper
public struct GraphQLResponse<Data: Codable>: Codable {
    public let data: Data?
    public let errors: [GraphQLError]?

    public init(data: Data?, errors: [GraphQLError]?) {
        self.data = data
        self.errors = errors
    }
}

/// GraphQL error structure
public struct GraphQLError: Codable {
    public let message: String
    public let locations: [ErrorLocation]?
    public let path: [String]?

    public init(message: String, locations: [ErrorLocation]?, path: [String]?) {
        self.message = message
        self.locations = locations
        self.path = path
    }
}

/// GraphQL error location
public struct ErrorLocation: Codable {
    public let line: Int
    public let column: Int

    public init(line: Int, column: Int) {
        self.line = line
        self.column = column
    }
}

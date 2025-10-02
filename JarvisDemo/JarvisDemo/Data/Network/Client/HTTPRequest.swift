//
//  HTTPRequest.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import Foundation

struct HTTPRequest {
    let url: String
    let method: HTTPMethod
    let headers: [String: String]
    let body: Data?
    let timeout: TimeInterval

    init(
        url: String,
        method: HTTPMethod = .GET,
        headers: [String: String] = [:],
        body: Data? = nil,
        timeout: TimeInterval = 30.0
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.timeout = timeout
    }
}

// MARK: - Convenience Initializers

extension HTTPRequest {
    static func get(
        url: String,
        headers: [String: String] = [:]
    ) -> HTTPRequest {
        return HTTPRequest(url: url, method: .GET, headers: headers)
    }

    static func post<T: Codable>(
        url: String,
        body: T,
        headers: [String: String] = [:]
    ) throws -> HTTPRequest {
        let encoder = JSONEncoder()
        let bodyData = try encoder.encode(body)
        var requestHeaders = headers
        requestHeaders["Content-Type"] = "application/json"

        return HTTPRequest(
            url: url,
            method: .POST,
            headers: requestHeaders,
            body: bodyData
        )
    }

    static func put<T: Codable>(
        url: String,
        body: T,
        headers: [String: String] = [:]
    ) throws -> HTTPRequest {
        let encoder = JSONEncoder()
        let bodyData = try encoder.encode(body)
        var requestHeaders = headers
        requestHeaders["Content-Type"] = "application/json"

        return HTTPRequest(
            url: url,
            method: .PUT,
            headers: requestHeaders,
            body: bodyData
        )
    }

    static func patch<T: Codable>(
        url: String,
        body: T,
        headers: [String: String] = [:]
    ) throws -> HTTPRequest {
        let encoder = JSONEncoder()
        let bodyData = try encoder.encode(body)
        var requestHeaders = headers
        requestHeaders["Content-Type"] = "application/json"

        return HTTPRequest(
            url: url,
            method: .PATCH,
            headers: requestHeaders,
            body: bodyData
        )
    }

    static func delete(
        url: String,
        headers: [String: String] = [:]
    ) -> HTTPRequest {
        return HTTPRequest(url: url, method: .DELETE, headers: headers)
    }
}
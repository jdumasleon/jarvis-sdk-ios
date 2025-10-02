//
//  HTTPResponse.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import Foundation

struct HTTPResponse {
    let data: Data
    let statusCode: Int
    let headers: [String: String]
    let url: String?

    var isSuccessful: Bool {
        return 200...299 ~= statusCode
    }
}

// MARK: - Decoding Helpers

extension HTTPResponse {
    func decode<T: Codable>(_ type: T.Type, using decoder: JSONDecoder = JSONDecoder()) throws -> T {
        return try decoder.decode(type, from: data)
    }

    func decodeIfPresent<T: Codable>(_ type: T.Type, using decoder: JSONDecoder = JSONDecoder()) -> T? {
        return try? decoder.decode(type, from: data)
    }
}
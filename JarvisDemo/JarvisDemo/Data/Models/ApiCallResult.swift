//
//  ApiCallResult.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import Foundation

struct ApiCallResult: Identifiable, Hashable {
    let id = UUID()
    let url: String
    let host: String
    let method: String
    let startTime: Int64
    let endTime: Int64
    let isSuccess: Bool
    let statusCode: Int
    let error: String?

    var duration: Int64 {
        endTime - startTime
    }

    var timestamp: String {
        let date = Date(timeIntervalSince1970: TimeInterval(startTime) / 1000.0)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }

    init(
        url: String,
        host: String,
        method: String,
        startTime: Int64,
        endTime: Int64,
        isSuccess: Bool,
        statusCode: Int,
        error: String? = nil
    ) {
        self.url = url
        self.host = host
        self.method = method
        self.startTime = startTime
        self.endTime = endTime
        self.isSuccess = isSuccess
        self.statusCode = statusCode
        self.error = error
    }
}

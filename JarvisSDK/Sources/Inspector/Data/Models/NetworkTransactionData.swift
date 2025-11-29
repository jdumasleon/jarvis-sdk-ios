import Foundation
import JarvisCommon
import JarvisData

/// Network transaction data model
public struct NetworkTransactionData: JarvisModel {
    public let id: String
    public let requestId: String
    public let responseId: String?
    public let method: String
    public let url: String
    public let requestHeaders: [String: String]
    public let requestBody: Data?
    public let responseHeaders: [String: String]?
    public let responseBody: Data?
    public let statusCode: Int?
    public let startTime: Date
    public let endTime: Date?
    public let status: String

    public init(
        id: String = UUID().uuidString,
        requestId: String,
        responseId: String? = nil,
        method: String,
        url: String,
        requestHeaders: [String: String] = [:],
        requestBody: Data? = nil,
        responseHeaders: [String: String]? = nil,
        responseBody: Data? = nil,
        statusCode: Int? = nil,
        startTime: Date = Date(),
        endTime: Date? = nil,
        status: String
    ) {
        self.id = id
        self.requestId = requestId
        self.responseId = responseId
        self.method = method
        self.url = url
        self.requestHeaders = requestHeaders
        self.requestBody = requestBody
        self.responseHeaders = responseHeaders
        self.responseBody = responseBody
        self.statusCode = statusCode
        self.startTime = startTime
        self.endTime = endTime
        self.status = status
    }
}

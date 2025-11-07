import Foundation

/// Entity for network transaction storage (iOS 16+ compatible)
public final class NetworkTransactionEntity: Codable {
    public var id: String
    public var requestId: String
    public var responseId: String?
    public var method: String
    public var url: String

    // Store headers as JSON string
    public var requestHeadersJSON: String
    public var responseHeadersJSON: String?

    public var requestBody: Data?
    public var responseBody: Data?

    public var statusCode: Int?
    public var startTime: Date
    public var endTime: Date?
    public var status: String

    // New fields for enhanced detail view
    public var httpProtocol: String?
    public var path: String?
    public var host: String?
    public var requestTimestamp: Int64
    public var requestBodySize: Int64
    public var responseTimestamp: Int64
    public var responseBodySize: Int64
    public var statusMessage: String?
    public var error: String?

    public init(
        id: String,
        requestId: String,
        responseId: String? = nil,
        method: String,
        url: String,
        requestHeadersJSON: String,
        responseHeadersJSON: String? = nil,
        requestBody: Data? = nil,
        responseBody: Data? = nil,
        statusCode: Int? = nil,
        startTime: Date,
        endTime: Date? = nil,
        status: String,
        httpProtocol: String? = nil,
        path: String? = nil,
        host: String? = nil,
        requestTimestamp: Int64 = 0,
        requestBodySize: Int64 = 0,
        responseTimestamp: Int64 = 0,
        responseBodySize: Int64 = 0,
        statusMessage: String? = nil,
        error: String? = nil
    ) {
        self.id = id
        self.requestId = requestId
        self.responseId = responseId
        self.method = method
        self.url = url
        self.requestHeadersJSON = requestHeadersJSON
        self.responseHeadersJSON = responseHeadersJSON
        self.requestBody = requestBody
        self.responseBody = responseBody
        self.statusCode = statusCode
        self.startTime = startTime
        self.endTime = endTime
        self.status = status
        self.httpProtocol = httpProtocol
        self.path = path
        self.host = host
        self.requestTimestamp = requestTimestamp
        self.requestBodySize = requestBodySize
        self.responseTimestamp = responseTimestamp
        self.responseBodySize = responseBodySize
        self.statusMessage = statusMessage
        self.error = error
    }

    // Helper to convert headers dictionary to JSON
    public static func encodeHeaders(_ headers: [String: String]) -> String {
        guard let data = try? JSONEncoder().encode(headers),
              let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return json
    }

    // Helper to convert JSON back to headers dictionary
    public static func decodeHeaders(_ json: String) -> [String: String] {
        guard let data = json.data(using: .utf8),
              let headers = try? JSONDecoder().decode([String: String].self, from: data) else {
            return [:]
        }
        return headers
    }
}

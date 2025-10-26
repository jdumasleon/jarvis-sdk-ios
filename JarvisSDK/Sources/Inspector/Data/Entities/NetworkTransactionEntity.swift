import Foundation
import SwiftData

/// SwiftData entity for persistent network transaction storage
@available(iOS 17.0, *)
@Model
public final class NetworkTransactionEntity {
    @Attribute(.unique) public var id: String
    public var requestId: String
    public var responseId: String?
    public var method: String
    public var url: String

    // Store headers as JSON string for SwiftData compatibility
    public var requestHeadersJSON: String
    public var responseHeadersJSON: String?

    @Attribute(.externalStorage) public var requestBody: Data?
    @Attribute(.externalStorage) public var responseBody: Data?

    public var statusCode: Int?
    public var startTime: Date
    public var endTime: Date?
    public var status: String

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
        status: String
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

import Foundation
import JarvisDomain

/// Filter for network transactions
public struct TransactionFilter {
    public let method: HTTPMethod?
    public let statusCode: Int?
    public let searchTerm: String?
    public let timeRange: DateInterval?

    public init(
        method: HTTPMethod? = nil,
        statusCode: Int? = nil,
        searchTerm: String? = nil,
        timeRange: DateInterval? = nil
    ) {
        self.method = method
        self.statusCode = statusCode
        self.searchTerm = searchTerm
        self.timeRange = timeRange
    }
}

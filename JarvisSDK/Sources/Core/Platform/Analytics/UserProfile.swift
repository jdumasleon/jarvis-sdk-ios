import Foundation

/// User profile information for analytics
public struct UserProfile {
    public let userId: String
    public let properties: [String: Any]
    public let email: String?
    public let name: String?

    public init(
        userId: String,
        properties: [String: Any] = [:],
        email: String? = nil,
        name: String? = nil
    ) {
        self.userId = userId
        self.properties = properties
        self.email = email
        self.name = name
    }
}

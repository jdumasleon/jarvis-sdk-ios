import Foundation
import Common
import Data

/// Preference change data model
public struct PreferenceChangeData: JarvisModel {
    public let id: String
    public let key: String
    public let oldValueData: Data?
    public let newValueData: Data?
    public let valueType: String
    public let timestamp: Date
    public let source: String

    public init(
        id: String = UUID().uuidString,
        key: String,
        oldValueData: Data? = nil,
        newValueData: Data?,
        valueType: String,
        timestamp: Date = Date(),
        source: String
    ) {
        self.id = id
        self.key = key
        self.oldValueData = oldValueData
        self.newValueData = newValueData
        self.valueType = valueType
        self.timestamp = timestamp
        self.source = source
    }
}
import Foundation
import Common
import Data
import Domain
import JarvisPreferencesDomain

/// Repository for preference change data
public class PreferenceChangeRepository: PreferenceChangeRepositoryProtocol {
    private var changes: [PreferenceChangeData] = []

    public init() {
        // In-memory storage for now
    }

    public func save(_ change: PreferenceChange) async throws {
        let data = PreferenceChangeData(
            id: change.id,
            key: change.key,
            oldValueData: try? JSONSerialization.data(withJSONObject: change.oldValue ?? NSNull()),
            newValueData: try? JSONSerialization.data(withJSONObject: change.newValue ?? NSNull()),
            valueType: String(describing: type(of: change.newValue)),
            timestamp: change.timestamp,
            source: change.source.rawValue
        )

        changes.append(data)
    }

    public func fetch(id: String) async throws -> PreferenceChange? {
        if let data = changes.first(where: { $0.id == id }) {
            return convertToEntity(data)
        }
        return nil
    }

    public func fetchAll() async throws -> [PreferenceChange] {
        return changes.compactMap(convertToEntity)
    }

    public func delete(id: String) async throws {
        changes.removeAll { $0.id == id }
    }

    public func deleteAll() async throws {
        changes.removeAll()
    }

    public func fetchByKey(_ key: String) async throws -> [PreferenceChange] {
        let filtered = changes.filter { $0.key == key }
        return filtered.compactMap(convertToEntity)
    }

    public func fetchBySource(_ source: PreferenceSource) async throws -> [PreferenceChange] {
        let filtered = changes.filter { $0.source == source.rawValue }
        return filtered.compactMap(convertToEntity)
    }

    public func fetchRecent(limit: Int = 100) async throws -> [PreferenceChange] {
        let recent = Array(changes.suffix(limit))
        return recent.compactMap(convertToEntity)
    }

    private func convertToEntity(_ data: PreferenceChangeData) -> PreferenceChange? {
        guard let source = PreferenceSource(rawValue: data.source) else { return nil }

        // Convert data back to original value types
        var oldValue: Any?
        var newValue: Any?

        if let oldData = data.oldValueData {
            oldValue = try? JSONSerialization.jsonObject(with: oldData)
        }

        if let newData = data.newValueData {
            newValue = try? JSONSerialization.jsonObject(with: newData)
        }

        return PreferenceChange(
            id: data.id,
            key: data.key,
            oldValue: oldValue,
            newValue: newValue,
            timestamp: data.timestamp,
            source: source
        )
    }
}
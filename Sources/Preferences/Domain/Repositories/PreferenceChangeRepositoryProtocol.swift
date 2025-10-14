import Foundation

/// Protocol for preference change repository
public protocol PreferenceChangeRepositoryProtocol {
    func save(_ change: PreferenceChange) async throws
    func fetch(id: String) async throws -> PreferenceChange?
    func fetchAll() async throws -> [PreferenceChange]
    func delete(id: String) async throws
    func deleteAll() async throws
    func fetchByKey(_ key: String) async throws -> [PreferenceChange]
    func fetchBySource(_ source: PreferenceSource) async throws -> [PreferenceChange]
    func fetchRecent(limit: Int) async throws -> [PreferenceChange]
}
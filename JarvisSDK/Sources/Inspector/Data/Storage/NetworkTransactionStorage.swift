import Foundation
import SwiftData

/// SwiftData storage manager for network transactions
@available(iOS 17.0, *)
@MainActor
public class NetworkTransactionStorage {
    public static let shared = NetworkTransactionStorage()

    private var modelContainer: ModelContainer?
    private var modelContext: ModelContext?

    private init() {
        setupStorage()
    }

    private func setupStorage() {
        do {
            let schema = Schema([NetworkTransactionEntity.self])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                groupContainer: .none,
                cloudKitDatabase: .none
            )
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            modelContext = ModelContext(modelContainer!)
        } catch {
            print("❌ Failed to initialize SwiftData storage: \(error)")
            // Fallback to in-memory if persistent fails
            setupInMemoryStorage()
        }
    }

    private func setupInMemoryStorage() {
        do {
            let schema = Schema([NetworkTransactionEntity.self])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            modelContext = ModelContext(modelContainer!)
        } catch {
            print("❌ Failed to initialize in-memory storage: \(error)")
        }
    }

    // MARK: - CRUD Operations

    public func save(_ entity: NetworkTransactionEntity) throws {
        guard let context = modelContext else {
            throw StorageError.contextNotAvailable
        }

        context.insert(entity)
        try context.save()
    }

    public func fetch(id: String) throws -> NetworkTransactionEntity? {
        guard let context = modelContext else {
            throw StorageError.contextNotAvailable
        }

        let predicate = #Predicate<NetworkTransactionEntity> { transaction in
            transaction.id == id
        }

        let descriptor = FetchDescriptor<NetworkTransactionEntity>(predicate: predicate)
        let results = try context.fetch(descriptor)
        return results.first
    }

    public func fetchAll() throws -> [NetworkTransactionEntity] {
        guard let context = modelContext else {
            throw StorageError.contextNotAvailable
        }

        let descriptor = FetchDescriptor<NetworkTransactionEntity>(
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    public func fetchRecent(limit: Int) throws -> [NetworkTransactionEntity] {
        guard let context = modelContext else {
            throw StorageError.contextNotAvailable
        }

        var descriptor = FetchDescriptor<NetworkTransactionEntity>(
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try context.fetch(descriptor)
    }

    public func fetchByMethod(_ method: String) throws -> [NetworkTransactionEntity] {
        guard let context = modelContext else {
            throw StorageError.contextNotAvailable
        }

        let predicate = #Predicate<NetworkTransactionEntity> { transaction in
            transaction.method == method
        }

        let descriptor = FetchDescriptor<NetworkTransactionEntity>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    public func fetchByStatusCode(_ statusCode: Int) throws -> [NetworkTransactionEntity] {
        guard let context = modelContext else {
            throw StorageError.contextNotAvailable
        }

        let predicate = #Predicate<NetworkTransactionEntity> { transaction in
            transaction.statusCode == statusCode
        }

        let descriptor = FetchDescriptor<NetworkTransactionEntity>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    public func delete(id: String) throws {
        guard let context = modelContext else {
            throw StorageError.contextNotAvailable
        }

        if let entity = try fetch(id: id) {
            context.delete(entity)
            try context.save()
        }
    }

    public func deleteAll() throws {
        guard let context = modelContext else {
            throw StorageError.contextNotAvailable
        }

        let all = try fetchAll()
        for entity in all {
            context.delete(entity)
        }
        try context.save()
    }

    // MARK: - Errors

    public enum StorageError: Error {
        case contextNotAvailable
        case fetchFailed
        case saveFailed
        case deleteFailed
    }
}

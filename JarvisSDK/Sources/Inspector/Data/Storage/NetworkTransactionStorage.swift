import Foundation

/// Storage manager for network transactions (iOS 16+ compatible)
@MainActor
public class NetworkTransactionStorage {
    public static let shared = NetworkTransactionStorage()

    private var transactions: [NetworkTransactionEntity] = []
    private let fileURL: URL
    private let queue = DispatchQueue(label: "com.jarvis.networkstorage", qos: .utility)

    private init() {
        // Set up file storage location
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = documentsPath.appendingPathComponent("network_transactions.json")

        // Load existing transactions from disk
        loadFromDisk()
    }

    private func loadFromDisk() {
        queue.async { [weak self] in
            guard let self = self,
                  FileManager.default.fileExists(atPath: self.fileURL.path),
                  let data = try? Data(contentsOf: self.fileURL),
                  let loaded = try? JSONDecoder().decode([NetworkTransactionEntity].self, from: data) else {
                return
            }

            Task { @MainActor in
                self.transactions = loaded
            }
        }
    }

    private func saveToDisk() {
        queue.async { [weak self] in
            guard let self = self else { return }

            Task { @MainActor in
                let currentTransactions = self.transactions
                self.queue.async {
                    if let data = try? JSONEncoder().encode(currentTransactions) {
                        try? data.write(to: self.fileURL, options: .atomic)
                    }
                }
            }
        }
    }

    // MARK: - CRUD Operations

    public func save(_ entity: NetworkTransactionEntity) throws {
        // Remove existing entity with same ID if present
        transactions.removeAll { $0.id == entity.id }

        // Add new entity
        transactions.append(entity)

        // Persist to disk
        saveToDisk()
    }

    public func fetch(id: String) throws -> NetworkTransactionEntity? {
        return transactions.first { $0.id == id }
    }

    public func fetchAll() throws -> [NetworkTransactionEntity] {
        return transactions.sorted { $0.startTime > $1.startTime }
    }

    public func fetchRecent(limit: Int) throws -> [NetworkTransactionEntity] {
        return Array(transactions
            .sorted { $0.startTime > $1.startTime }
            .prefix(limit))
    }

    public func fetchByMethod(_ method: String) throws -> [NetworkTransactionEntity] {
        return transactions
            .filter { $0.method == method }
            .sorted { $0.startTime > $1.startTime }
    }

    public func fetchByStatusCode(_ statusCode: Int) throws -> [NetworkTransactionEntity] {
        return transactions
            .filter { $0.statusCode == statusCode }
            .sorted { $0.startTime > $1.startTime }
    }

    public func delete(id: String) throws {
        transactions.removeAll { $0.id == id }
        saveToDisk()
    }

    public func deleteAll() throws {
        transactions.removeAll()
        saveToDisk()
    }

    // MARK: - Errors

    public enum StorageError: Error {
        case fetchFailed
        case saveFailed
        case deleteFailed
    }
}

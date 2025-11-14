import Foundation
import CoreData
import Domain

/// Core Data-based storage for network transactions
/// Replaces previous JSON/in-memory storage for better performance and persistence
@MainActor
public class NetworkTransactionStorage {
    public static let shared = NetworkTransactionStorage()

    private let coreDataStack = NetworkInspectorCoreDataStack.shared

    private init() {}

    // MARK: - CRUD Operations

    public func save(_ entity: NetworkTransactionEntity) throws {
        let context = coreDataStack.context

        // Check if exists
        let fetchRequest = NetworkTransactionManagedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", entity.id)

        let managedObject: NetworkTransactionManagedObject
        if let existing = try context.fetch(fetchRequest).first {
            managedObject = existing
        } else {
            managedObject = NetworkTransactionManagedObject(context: context)
            managedObject.id = entity.id
        }

        // Update properties
        managedObject.requestId = entity.requestId
        managedObject.responseId = entity.responseId
        managedObject.method = entity.method
        managedObject.url = entity.url
        managedObject.requestHeadersJSON = entity.requestHeadersJSON
        managedObject.requestBody = entity.requestBody.flatMap { String(data: $0, encoding: .utf8) }
        managedObject.responseHeadersJSON = entity.responseHeadersJSON
        managedObject.responseBody = entity.responseBody.flatMap { String(data: $0, encoding: .utf8) }
        managedObject.statusCode = Int64(entity.statusCode ?? 0)
        managedObject.startTime = entity.startTime
        managedObject.endTime = entity.endTime
        managedObject.status = entity.status

        // New fields
        managedObject.httpProtocol = entity.httpProtocol
        managedObject.path = entity.path
        managedObject.host = entity.host
        managedObject.requestTimestamp = entity.requestTimestamp
        managedObject.requestBodySize = entity.requestBodySize
        managedObject.responseTimestamp = entity.responseTimestamp
        managedObject.responseBodySize = entity.responseBodySize
        managedObject.statusMessage = entity.statusMessage
        managedObject.error = entity.error

        try coreDataStack.save()
    }

    public func fetch(id: String) throws -> NetworkTransactionEntity? {
        let context = coreDataStack.context
        let fetchRequest = NetworkTransactionManagedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.fetchLimit = 1

        guard let managedObject = try context.fetch(fetchRequest).first else {
            return nil
        }

        return convertToEntity(managedObject)
    }

    public func fetchAll() throws -> [NetworkTransactionEntity] {
        let context = coreDataStack.context
        let managedObjects = try context.fetch(NetworkTransactionManagedObject.fetchAll())
        return managedObjects.map(convertToEntity)
    }

    public func fetchRecent(limit: Int) throws -> [NetworkTransactionEntity] {
        let context = coreDataStack.context
        let managedObjects = try context.fetch(NetworkTransactionManagedObject.fetchRecent(limit: limit))
        return managedObjects.map(convertToEntity)
    }

    public func fetchByMethod(_ method: String) throws -> [NetworkTransactionEntity] {
        let context = coreDataStack.context
        let managedObjects = try context.fetch(NetworkTransactionManagedObject.fetchByMethod(method))
        return managedObjects.map(convertToEntity)
    }

    public func fetchByStatusCode(_ statusCode: Int) throws -> [NetworkTransactionEntity] {
        let context = coreDataStack.context
        let managedObjects = try context.fetch(NetworkTransactionManagedObject.fetchByStatusCode(statusCode))
        return managedObjects.map(convertToEntity)
    }

    public func search(_ query: String) throws -> [NetworkTransactionEntity] {
        let context = coreDataStack.context
        let managedObjects = try context.fetch(NetworkTransactionManagedObject.search(query))
        return managedObjects.map(convertToEntity)
    }

    public func delete(id: String) throws {
        let context = coreDataStack.context
        let fetchRequest = NetworkTransactionManagedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)

        let objects = try context.fetch(fetchRequest)
        objects.forEach { context.delete($0) }

        try coreDataStack.save()
    }

    public func deleteAll() throws {
        let context = coreDataStack.context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NetworkTransactionEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        try context.execute(deleteRequest)
        try coreDataStack.save()
    }

    public func deleteOldTransactions(beforeTimestamp: TimeInterval) throws {
        let context = coreDataStack.context
        let cutoffDate = Date(timeIntervalSince1970: beforeTimestamp)

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NetworkTransactionEntity")
        fetchRequest.predicate = NSPredicate(format: "startTime < %@", cutoffDate as NSDate)

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        try context.execute(deleteRequest)
        try coreDataStack.save()
    }

    // MARK: - Conversion

    private func convertToEntity(_ managedObject: NetworkTransactionManagedObject) -> NetworkTransactionEntity {
        return NetworkTransactionEntity(
            id: managedObject.id,
            requestId: managedObject.requestId,
            responseId: managedObject.responseId,
            method: managedObject.method,
            url: managedObject.url,
            requestHeadersJSON: managedObject.requestHeadersJSON ?? "",
            responseHeadersJSON: managedObject.responseHeadersJSON,
            requestBody: managedObject.requestBody?.data(using: .utf8),
            responseBody: managedObject.responseBody?.data(using: .utf8),
            statusCode: managedObject.statusCode > 0 ? Int(managedObject.statusCode) : nil,
            startTime: managedObject.startTime,
            endTime: managedObject.endTime,
            status: managedObject.status,
            httpProtocol: managedObject.httpProtocol,
            path: managedObject.path,
            host: managedObject.host,
            requestTimestamp: managedObject.requestTimestamp,
            requestBodySize: managedObject.requestBodySize,
            responseTimestamp: managedObject.responseTimestamp,
            responseBodySize: managedObject.responseBodySize,
            statusMessage: managedObject.statusMessage,
            error: managedObject.error
        )
    }

    // MARK: - Errors

    public enum StorageError: Error {
        case fetchFailed
        case saveFailed
        case deleteFailed
    }
}

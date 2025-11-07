import Foundation
import CoreData

/// Core Data stack for Network Inspector
/// Manages persistent storage of network transactions using Core Data
@MainActor
public class NetworkInspectorCoreDataStack {
    public static let shared = NetworkInspectorCoreDataStack()

    private let modelName = "NetworkInspector"
    private let schemaVersion = 3 // Increment this when schema changes (added requestId and responseId)
    private let versionKey = "NetworkInspectorSchemaVersion"

    lazy var persistentContainer: NSPersistentContainer = {
        // Check if we need to migrate/reset the database
        checkAndMigrateIfNeeded()
        // Create model programmatically
        let model = createManagedObjectModel()
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)

        // Store in app's Application Support directory
        let storeURL = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Jarvis")
            .appendingPathComponent("\(modelName).sqlite")

        // Create directory if needed
        try? FileManager.default.createDirectory(
            at: storeURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true

        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { description, error in
            if let error = error {
                // In production, handle error gracefully
                print("⚠️ Core Data store failed to load: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func save() throws {
        guard context.hasChanges else { return }
        try context.save()
    }

    // MARK: - Model Creation

    private func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // Create entity
        let entity = NSEntityDescription()
        entity.name = "NetworkTransactionEntity"
        entity.managedObjectClassName = NSStringFromClass(NetworkTransactionManagedObject.self)

        // Create attributes
        var properties: [NSAttributeDescription] = []

        // id - required
        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .stringAttributeType
        idAttr.isOptional = false
        properties.append(idAttr)

        // requestId - required
        let requestIdAttr = NSAttributeDescription()
        requestIdAttr.name = "requestId"
        requestIdAttr.attributeType = .stringAttributeType
        requestIdAttr.isOptional = false
        properties.append(requestIdAttr)

        // responseId - optional
        let responseIdAttr = NSAttributeDescription()
        responseIdAttr.name = "responseId"
        responseIdAttr.attributeType = .stringAttributeType
        responseIdAttr.isOptional = true
        properties.append(responseIdAttr)

        // method - required
        let methodAttr = NSAttributeDescription()
        methodAttr.name = "method"
        methodAttr.attributeType = .stringAttributeType
        methodAttr.isOptional = false
        properties.append(methodAttr)

        // url - required
        let urlAttr = NSAttributeDescription()
        urlAttr.name = "url"
        urlAttr.attributeType = .stringAttributeType
        urlAttr.isOptional = false
        properties.append(urlAttr)

        // requestHeadersJSON - optional
        let requestHeadersAttr = NSAttributeDescription()
        requestHeadersAttr.name = "requestHeadersJSON"
        requestHeadersAttr.attributeType = .stringAttributeType
        requestHeadersAttr.isOptional = true
        properties.append(requestHeadersAttr)

        // requestBody - optional
        let requestBodyAttr = NSAttributeDescription()
        requestBodyAttr.name = "requestBody"
        requestBodyAttr.attributeType = .stringAttributeType
        requestBodyAttr.isOptional = true
        properties.append(requestBodyAttr)

        // responseHeadersJSON - optional
        let responseHeadersAttr = NSAttributeDescription()
        responseHeadersAttr.name = "responseHeadersJSON"
        responseHeadersAttr.attributeType = .stringAttributeType
        responseHeadersAttr.isOptional = true
        properties.append(responseHeadersAttr)

        // responseBody - optional
        let responseBodyAttr = NSAttributeDescription()
        responseBodyAttr.name = "responseBody"
        responseBodyAttr.attributeType = .stringAttributeType
        responseBodyAttr.isOptional = true
        properties.append(responseBodyAttr)

        // statusCode - optional
        let statusCodeAttr = NSAttributeDescription()
        statusCodeAttr.name = "statusCode"
        statusCodeAttr.attributeType = .integer64AttributeType
        statusCodeAttr.isOptional = true
        statusCodeAttr.defaultValue = 0
        properties.append(statusCodeAttr)

        // startTime - required
        let startTimeAttr = NSAttributeDescription()
        startTimeAttr.name = "startTime"
        startTimeAttr.attributeType = .dateAttributeType
        startTimeAttr.isOptional = false
        properties.append(startTimeAttr)

        // endTime - optional
        let endTimeAttr = NSAttributeDescription()
        endTimeAttr.name = "endTime"
        endTimeAttr.attributeType = .dateAttributeType
        endTimeAttr.isOptional = true
        properties.append(endTimeAttr)

        // status - required
        let statusAttr = NSAttributeDescription()
        statusAttr.name = "status"
        statusAttr.attributeType = .stringAttributeType
        statusAttr.isOptional = false
        properties.append(statusAttr)

        // httpProtocol - optional
        let httpProtocolAttr = NSAttributeDescription()
        httpProtocolAttr.name = "httpProtocol"
        httpProtocolAttr.attributeType = .stringAttributeType
        httpProtocolAttr.isOptional = true
        properties.append(httpProtocolAttr)

        // path - optional
        let pathAttr = NSAttributeDescription()
        pathAttr.name = "path"
        pathAttr.attributeType = .stringAttributeType
        pathAttr.isOptional = true
        properties.append(pathAttr)

        // host - optional
        let hostAttr = NSAttributeDescription()
        hostAttr.name = "host"
        hostAttr.attributeType = .stringAttributeType
        hostAttr.isOptional = true
        properties.append(hostAttr)

        // requestTimestamp - optional
        let requestTimestampAttr = NSAttributeDescription()
        requestTimestampAttr.name = "requestTimestamp"
        requestTimestampAttr.attributeType = .integer64AttributeType
        requestTimestampAttr.isOptional = true
        requestTimestampAttr.defaultValue = 0
        properties.append(requestTimestampAttr)

        // requestBodySize - optional
        let requestBodySizeAttr = NSAttributeDescription()
        requestBodySizeAttr.name = "requestBodySize"
        requestBodySizeAttr.attributeType = .integer64AttributeType
        requestBodySizeAttr.isOptional = true
        requestBodySizeAttr.defaultValue = 0
        properties.append(requestBodySizeAttr)

        // responseTimestamp - optional
        let responseTimestampAttr = NSAttributeDescription()
        responseTimestampAttr.name = "responseTimestamp"
        responseTimestampAttr.attributeType = .integer64AttributeType
        responseTimestampAttr.isOptional = true
        responseTimestampAttr.defaultValue = 0
        properties.append(responseTimestampAttr)

        // responseBodySize - optional
        let responseBodySizeAttr = NSAttributeDescription()
        responseBodySizeAttr.name = "responseBodySize"
        responseBodySizeAttr.attributeType = .integer64AttributeType
        responseBodySizeAttr.isOptional = true
        responseBodySizeAttr.defaultValue = 0
        properties.append(responseBodySizeAttr)

        // statusMessage - optional
        let statusMessageAttr = NSAttributeDescription()
        statusMessageAttr.name = "statusMessage"
        statusMessageAttr.attributeType = .stringAttributeType
        statusMessageAttr.isOptional = true
        properties.append(statusMessageAttr)

        // error - optional
        let errorAttr = NSAttributeDescription()
        errorAttr.name = "error"
        errorAttr.attributeType = .stringAttributeType
        errorAttr.isOptional = true
        properties.append(errorAttr)

        entity.properties = properties

        model.entities = [entity]

        return model
    }

    // MARK: - Schema Version Management

    private func checkAndMigrateIfNeeded() {
        let defaults = UserDefaults.standard
        let savedVersion = defaults.integer(forKey: versionKey)

        if savedVersion != schemaVersion {
            // Schema version has changed, delete the old database
            let storeURL = FileManager.default
                .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("Jarvis")
                .appendingPathComponent("\(modelName).sqlite")

            // Remove all Core Data files
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: storeURL.path) {
                try? fileManager.removeItem(at: storeURL)
            }
            // Also remove WAL and SHM files
            try? fileManager.removeItem(at: storeURL.deletingPathExtension().appendingPathExtension("sqlite-wal"))
            try? fileManager.removeItem(at: storeURL.deletingPathExtension().appendingPathExtension("sqlite-shm"))

            // Update version
            defaults.set(schemaVersion, forKey: versionKey)
            print("📦 NetworkInspector: Database reset due to schema change (v\(savedVersion) → v\(schemaVersion))")
        }
    }
}

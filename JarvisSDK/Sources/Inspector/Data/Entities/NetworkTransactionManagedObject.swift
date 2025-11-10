import Foundation
import CoreData

@objc(NetworkTransactionManagedObject)
public class NetworkTransactionManagedObject: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var requestId: String
    @NSManaged public var responseId: String?
    @NSManaged public var method: String
    @NSManaged public var url: String
    @NSManaged public var requestHeadersJSON: String?
    @NSManaged public var requestBody: String?
    @NSManaged public var responseHeadersJSON: String?
    @NSManaged public var responseBody: String?
    @NSManaged public var statusCode: Int64
    @NSManaged public var startTime: Date
    @NSManaged public var endTime: Date?
    @NSManaged public var status: String

    // New fields for enhanced detail view
    @NSManaged public var httpProtocol: String?
    @NSManaged public var path: String?
    @NSManaged public var host: String?
    @NSManaged public var requestTimestamp: Int64
    @NSManaged public var requestBodySize: Int64
    @NSManaged public var responseTimestamp: Int64
    @NSManaged public var responseBodySize: Int64
    @NSManaged public var statusMessage: String?
    @NSManaged public var error: String?
}

extension NetworkTransactionManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<NetworkTransactionManagedObject> {
        return NSFetchRequest<NetworkTransactionManagedObject>(entityName: "NetworkTransactionEntity")
    }

    /// Fetch all transactions ordered by most recent
    static func fetchAll() -> NSFetchRequest<NetworkTransactionManagedObject> {
        let request = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        request.fetchLimit = 1000 // Match Android limit
        return request
    }

    /// Fetch recent transactions with limit
    static func fetchRecent(limit: Int) -> NSFetchRequest<NetworkTransactionManagedObject> {
        let request = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        request.fetchLimit = limit
        return request
    }

    /// Fetch by HTTP method
    static func fetchByMethod(_ method: String) -> NSFetchRequest<NetworkTransactionManagedObject> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "method == %@", method)
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        return request
    }

    /// Fetch by status code
    static func fetchByStatusCode(_ statusCode: Int) -> NSFetchRequest<NetworkTransactionManagedObject> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "statusCode == %d", statusCode)
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        return request
    }

    /// Search by URL or method
    static func search(_ query: String) -> NSFetchRequest<NetworkTransactionManagedObject> {
        let request = fetchRequest()
        request.predicate = NSPredicate(
            format: "url CONTAINS[cd] %@ OR method CONTAINS[cd] %@",
            query, query
        )
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        return request
    }
}

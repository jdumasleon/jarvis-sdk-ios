import Foundation
import JarvisInspectorDomain
import JarvisCommon

/// Simple network cleanup utility
/// Deletes network transactions older than 24 hours
public class NetworkCleanupScheduler {

    // MARK: - Constants

    private static let cleanupIntervalHours: TimeInterval = 24

    // MARK: - Properties

    private let repository: NetworkTransactionRepositoryProtocol

    // MARK: - Initialization

    public init(repository: NetworkTransactionRepositoryProtocol = NetworkTransactionRepository()) {
        self.repository = repository
    }

    // MARK: - Public Methods

    /// Perform cleanup of old network requests
    /// Deletes all transactions older than 24 hours
    public func performCleanup() async throws {
        // Calculate timestamp for 24 hours ago
        let twentyFourHoursAgo = Date().timeIntervalSince1970 - (Self.cleanupIntervalHours * 60 * 60)

        // Delete all requests older than 24 hours
        try await repository.deleteOldTransactions(beforeTimestamp: twentyFourHoursAgo)

        print("[NetworkCleanupScheduler] Successfully cleaned up network requests older than 24 hours")
    }
}

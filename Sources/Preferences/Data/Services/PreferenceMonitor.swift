import Foundation
import JarvisPreferencesDomain

/// Service for monitoring preference changes
public class PreferenceMonitor {
    public static let shared = PreferenceMonitor()

    private var isMonitoring = false
    private let repository: PreferenceChangeRepositoryProtocol
    private var observers: [NSObjectProtocol] = []

    public init(repository: PreferenceChangeRepositoryProtocol = PreferenceChangeRepository()) {
        self.repository = repository
    }

    public func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true

        // Monitor UserDefaults changes
        let observer = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleUserDefaultsChange(notification)
        }

        observers.append(observer)
    }

    public func stopMonitoring() {
        guard isMonitoring else { return }
        isMonitoring = false

        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
        observers.removeAll()
    }

    private func handleUserDefaultsChange(_ notification: Notification) {
        Task {
            // This is a simplified implementation
            // In reality, you'd need to track individual key changes
            let change = PreferenceChange(
                key: "user_defaults_change",
                newValue: "changed",
                source: .userDefaults
            )

            try? await repository.save(change)
        }
    }

    deinit {
        stopMonitoring()
    }
}
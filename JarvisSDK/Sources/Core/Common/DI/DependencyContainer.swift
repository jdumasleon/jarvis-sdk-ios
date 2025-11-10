//
//  DependencyContainer.swift
//  JarvisSDK
//
//  Thread-safe dependency injection container
//

import Foundation

/// Thread-safe dependency injection container
@MainActor
public final class DependencyContainer {
    /// Shared singleton instance
    public static let shared = DependencyContainer()

    /// Internal storage for dependency factories
    private var factories: [String: DependencyFactory] = [:]

    /// Internal storage for singleton instances
    private var singletons: [String: Any] = [:]

    /// Internal storage for scoped instances
    private var scopedInstances: [String: Any] = [:]

    /// Private initializer for singleton pattern
    private init() {}

    // MARK: - Registration

    /// Register a dependency with its factory and scope
    /// - Parameters:
    ///   - type: The type to register (can be a protocol or concrete type)
    ///   - scope: The lifecycle scope (default: singleton)
    ///   - factory: Closure that creates instances of the dependency
    public func register<T>(
        _ type: T.Type,
        scope: DependencyScope = .singleton,
        factory: @escaping () -> T
    ) {
        let key = String(describing: type)
        factories[key] = DependencyFactory(scope: scope, factory: factory)
    }

    /// Register a dependency with a specific instance (singleton only)
    /// - Parameters:
    ///   - type: The type to register
    ///   - instance: The instance to register
    public func register<T>(
        _ type: T.Type,
        instance: T
    ) {
        let key = String(describing: type)
        singletons[key] = instance
        factories[key] = DependencyFactory(scope: .singleton) { instance }
    }

    // MARK: - Resolution

    /// Resolve a dependency by type
    /// - Parameter type: The type to resolve
    /// - Returns: An instance of the requested type
    /// - Throws: DependencyError if the dependency is not registered
    public func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)

        guard let factory = factories[key] else {
            fatalError("Dependency not registered: \(key). Please register this dependency before attempting to resolve it.")
        }

        switch factory.scope {
        case .singleton:
            if let instance = singletons[key] as? T {
                return instance
            }
            let instance = factory.create() as! T
            singletons[key] = instance
            return instance

        case .transient:
            return factory.create() as! T

        case .scoped:
            if let instance = scopedInstances[key] as? T {
                return instance
            }
            let instance = factory.create() as! T
            scopedInstances[key] = instance
            return instance
        }
    }

    /// Optional resolution - returns nil if dependency is not registered
    /// - Parameter type: The type to resolve
    /// - Returns: An instance of the requested type, or nil if not registered
    public func resolveOptional<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)

        guard let factory = factories[key] else {
            return nil
        }

        switch factory.scope {
        case .singleton:
            if let instance = singletons[key] as? T {
                return instance
            }
            let instance = factory.create() as! T
            singletons[key] = instance
            return instance

        case .transient:
            return factory.create() as? T

        case .scoped:
            if let instance = scopedInstances[key] as? T {
                return instance
            }
            let instance = factory.create() as! T
            scopedInstances[key] = instance
            return instance
        }
    }

    // MARK: - Scope Management

    /// Clear all scoped instances (useful for clearing feature-level dependencies)
    public func clearScope() {
        scopedInstances.removeAll()
    }

    /// Clear all dependencies (for testing or cleanup)
    public func clear() {
        factories.removeAll()
        singletons.removeAll()
        scopedInstances.removeAll()
    }

    /// Check if a dependency is registered
    /// - Parameter type: The type to check
    /// - Returns: true if registered, false otherwise
    public func isRegistered<T>(_ type: T.Type) -> Bool {
        let key = String(describing: type)
        return factories[key] != nil
    }
}

// MARK: - Supporting Types

/// Internal factory wrapper
private struct DependencyFactory {
    let scope: DependencyScope
    let factory: () -> Any

    func create() -> Any {
        return factory()
    }
}

// MARK: - Convenience Extensions

public extension DependencyContainer {
    /// Register multiple dependencies at once using a builder pattern
    func registerBatch(_ registrations: () -> Void) {
        registrations()
    }
}

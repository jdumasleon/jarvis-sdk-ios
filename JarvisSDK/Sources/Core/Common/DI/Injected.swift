//
//  Injected.swift
//  JarvisSDK
//
//  Property wrapper for dependency injection
//

import Foundation

/// Property wrapper for injecting dependencies from the DependencyContainer
///
/// Usage:
/// ```swift
/// class MyViewModel {
///     @Injected var repository: MyRepositoryProtocol
///     @Injected var useCase: MyUseCase
/// }
/// ```
@MainActor
@propertyWrapper
public struct Injected<T> {
    private var dependency: T?

    /// The resolved dependency instance
    public var wrappedValue: T {
        mutating get {
            if dependency == nil {
                dependency = DependencyContainer.shared.resolve(T.self)
            }
            return dependency!
        }
        mutating set {
            dependency = newValue
        }
    }

    /// Initialize the property wrapper
    public init() {
        self.dependency = nil
    }

    /// Initialize with a custom container (useful for testing)
    public init(container: DependencyContainer) {
        self.dependency = container.resolve(T.self)
    }
}

/// Property wrapper for optional dependency injection
///
/// Usage:
/// ```swift
/// class MyViewModel {
///     @InjectedOptional var optionalService: MyServiceProtocol?
/// }
/// ```
@MainActor
@propertyWrapper
public struct InjectedOptional<T> {
    private var dependency: T?
    private var resolved = false

    /// The resolved optional dependency instance
    public var wrappedValue: T? {
        mutating get {
            if !resolved {
                dependency = DependencyContainer.shared.resolveOptional(T.self)
                resolved = true
            }
            return dependency
        }
        mutating set {
            dependency = newValue
            resolved = true
        }
    }

    /// Initialize the property wrapper
    public init() {
        self.dependency = nil
        self.resolved = false
    }
}

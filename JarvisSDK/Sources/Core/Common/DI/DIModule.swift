//
//  DIModule.swift
//  JarvisSDK
//
//  Protocol for feature modules to implement DI registration
//

import Foundation

/// Protocol that feature modules implement to register their dependencies
@MainActor
public protocol DIModule {
    /// Register all dependencies for this module
    static func register(container: DependencyContainer)
}

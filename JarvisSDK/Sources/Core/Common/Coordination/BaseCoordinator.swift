//
//  BaseCoordinator.swift
//  JarvisSDK
//
//  Base coordinator with common navigation functionality
//

import Foundation

/// Base coordinator protocol providing common navigation methods
@MainActor
public protocol BaseCoordinator: AnyObject, ObservableObject {
    associatedtype Route: Hashable

    var routes: [Route] { get set }

    /// Navigate back one level
    func pop()

    /// Navigate to root (clear all routes)
    func popToRoot()
}

/// Default implementation of BaseCoordinator protocol
@MainActor
public extension BaseCoordinator {
    /// Navigate back one level
    func pop() {
        guard !routes.isEmpty else { return }
        routes.removeLast()
    }

    /// Navigate to root (clear all routes)
    func popToRoot() {
        routes.removeAll()
    }
}

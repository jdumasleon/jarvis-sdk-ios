//
//  RouteIdentifier.swift
//  JarvisSDK
//
//  Helper for identifying routes by a specific property
//  Enables Hashable conformance for navigation routes
//

import Foundation

/// Route identifier that wraps a value and makes it hashable by a specific ID
///
/// Usage:
/// ```swift
/// enum Route: Hashable {
///     case detail(RouteIdentifier<Movie>)
/// }
///
/// // Create route with movie, identified by its ID
/// let route = Route.detail(RouteIdentifier(value: movie, id: \.id))
/// ```
public struct RouteIdentifier<T>: Hashable {
    /// The wrapped value
    public let value: T

    /// The hashable identifier
    private let id: AnyHashable

    /// Create a route identifier
    /// - Parameters:
    ///   - value: The value to wrap
    ///   - id: Key path to the property to use as identifier
    public init<ID: Hashable>(value: T, id: (T) -> ID) {
        self.value = value
        self.id = AnyHashable(id(value))
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: RouteIdentifier<T>, rhs: RouteIdentifier<T>) -> Bool {
        return lhs.id == rhs.id
    }
}

//
//  InjectedObservable.swift
//  JarvisSDK
//
//  Property wrapper for injecting ObservableObject dependencies in SwiftUI
//

import SwiftUI
import Combine

/// Property wrapper for injecting ObservableObject dependencies in SwiftUI views
///
/// This wrapper automatically resolves the dependency and wraps it in @StateObject
/// for proper SwiftUI lifecycle management.
///
/// Usage:
/// ```swift
/// struct MyView: View {
///     @InjectedObservable var viewModel: MyViewModel
///
///     var body: some View {
///         Text(viewModel.title)
///     }
/// }
/// ```
@MainActor
@propertyWrapper
public struct InjectedObservable<T: ObservableObject>: DynamicProperty {
    @StateObject private var dependency: T

    /// The resolved observable dependency instance
    public var wrappedValue: T {
        dependency
    }

    /// Provides access to the projected value (like $viewModel)
    public var projectedValue: ObservedObject<T>.Wrapper {
        $dependency
    }

    /// Initialize the property wrapper
    /// This resolves the dependency immediately using DependencyContainer
    public init() {
        let resolved = DependencyContainer.shared.resolve(T.self)
        _dependency = StateObject(wrappedValue: resolved)
    }

    /// Initialize with a custom container (useful for testing)
    public init(container: DependencyContainer) {
        let resolved = container.resolve(T.self)
        _dependency = StateObject(wrappedValue: resolved)
    }
}

/// Property wrapper for injecting optional ObservableObject dependencies
///
/// Usage:
/// ```swift
/// struct MyView: View {
///     @InjectedObservableOptional var viewModel: MyViewModel?
///
///     var body: some View {
///         if let viewModel = viewModel {
///             Text(viewModel.title)
///         }
///     }
/// }
/// ```
@MainActor
@propertyWrapper
public struct InjectedObservableOptional<T: ObservableObject>: DynamicProperty {
    @State private var dependency: T?

    /// The resolved optional observable dependency instance
    public var wrappedValue: T? {
        dependency
    }

    /// Provides access to the projected value
    public var projectedValue: Binding<T?> {
        $dependency
    }

    /// Initialize the property wrapper
    public init() {
        let resolved = DependencyContainer.shared.resolveOptional(T.self)
        _dependency = State(initialValue: resolved)
    }

    /// Initialize with a custom container (useful for testing)
    public init(container: DependencyContainer) {
        let resolved = container.resolveOptional(T.self)
        _dependency = State(initialValue: resolved)
    }
}

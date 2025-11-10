//
//  DependencyScope.swift
//  JarvisSDK
//
//  Defines the lifecycle scope of dependencies
//

import Foundation

/// Lifecycle scope for dependency resolution
public enum DependencyScope {
    /// Single instance shared across the application lifetime
    case singleton

    /// New instance created on each resolution
    case transient

    /// Single instance per scope (useful for feature-level instances)
    case scoped
}

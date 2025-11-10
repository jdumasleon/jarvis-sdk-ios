//
//  Injectable.swift
//  JarvisSDK
//
//  Protocol marking types as injectable dependencies
//

import Foundation

/// Protocol that marks a type as injectable
/// This is a marker protocol to ensure type safety and provide compile-time guarantees
public protocol Injectable {
    /// Optionally, types can specify initialization requirements
    init()
}

/// Default implementation makes the protocol optional
public extension Injectable {
    // Types can provide custom initialization, but it's not required
}

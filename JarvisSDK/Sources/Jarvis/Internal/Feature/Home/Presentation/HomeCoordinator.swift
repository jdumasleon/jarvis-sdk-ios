//
//  HomeCoordinator.swift
//  JarvisSDK
//
//  Coordinator for Home feature navigation
//

import SwiftUI
import JarvisCommon

/// Home feature coordinator
/// Manages navigation within the Home tab
@MainActor
public final class HomeCoordinator: BaseCoordinator, ObservableObject {
    // MARK: - Properties

    /// Navigation routes stack
    @Published public var routes: [Route] = []

    /// Callback to dismiss the entire SDK
    var onDismissSDK: (() -> Void)?

    // MARK: - Initialization

    public init() {}

    // MARK: - Routes

    public enum Route: Hashable {
        // Add routes as Home feature grows
        // Example: case analytics, case statistics
    }
}

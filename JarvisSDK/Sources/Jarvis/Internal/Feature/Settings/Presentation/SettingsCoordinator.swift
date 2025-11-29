//
//  SettingsCoordinator.swift
//  JarvisSDK
//
//  Coordinator for Settings feature navigation
//

import SwiftUI
import JarvisCommon

/// Settings feature coordinator
/// Manages navigation within the Settings tab
@MainActor
public final class SettingsCoordinator: BaseCoordinator, ObservableObject {
    // MARK: - Properties

    /// Navigation routes stack
    @Published public var routes: [Route] = []

    /// Show app details sheet
    @Published public var showAppDetails: Bool = false

    /// Callback to dismiss the entire SDK
    var onDismissSDK: (() -> Void)?

    // MARK: - Initialization

    public init() {}

    // MARK: - Navigation

    /// Show app details
    public func showAppDetailsSheet() {
        showAppDetails = true
    }

    /// Dismiss app details
    public func dismissAppDetails() {
        showAppDetails = false
    }

    /// Show logging screen
    public func showLogging() {
        routes.append(.logging)
    }

    // MARK: - Routes

    public enum Route: Hashable {
        case logging
        // Add more routes as Settings feature grows
    }
}

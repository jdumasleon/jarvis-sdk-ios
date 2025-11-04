//
//  PreferencesCoordinator.swift
//  JarvisSDK
//
//  Coordinator for Preferences feature navigation
//

import SwiftUI
import Domain
import Common
import JarvisPreferencesDomain

/// Preferences feature coordinator
/// Manages navigation within the Preferences tab
@MainActor
public final class PreferencesCoordinator: BaseCoordinator, ObservableObject {
    // MARK: - Properties

    /// Navigation routes stack
    @Published public var routes: [Route] = []

    /// Callback to dismiss the entire SDK
    public var onDismissSDK: (() -> Void)?

    // MARK: - Initialization

    public init() {}

    // MARK: - Navigation

    /// Show preference detail
    public func showPreferenceDetail(for preference: Preference) {
        routes.append(.preferenceDetail(RouteIdentifier(value: preference, id: \.key)))
    }

    /// Show edit preference
    public func showEditPreference(for preference: Preference) {
        routes.append(.editPreference(RouteIdentifier(value: preference, id: \.key)))
    }

    // MARK: - Routes

    public enum Route: Hashable {
        case preferenceDetail(RouteIdentifier<Preference>)
        case editPreference(RouteIdentifier<Preference>)
    }
}

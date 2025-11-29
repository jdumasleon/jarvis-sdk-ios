//
//  InspectorCoordinator.swift
//  JarvisSDK
//
//  Coordinator for Network Inspector feature navigation
//

import SwiftUI
import JarvisCommon

/// Network Inspector feature coordinator
/// Manages navigation within the Inspector tab
@MainActor
public final class InspectorCoordinator: BaseCoordinator, ObservableObject {
    // MARK: - Properties

    /// Navigation routes stack
    @Published public var routes: [Route] = []

    /// Callback to dismiss the entire SDK
    public var onDismissSDK: (() -> Void)?

    // MARK: - Initialization

    public init() {}

    // MARK: - Navigation

    /// Show transaction detail
    public func showTransactionDetail(id: String) {
        routes.append(.transactionDetail(id: id))
    }

    // MARK: - Routes

    public enum Route: Hashable {
        case transactionDetail(id: String)
    }
}

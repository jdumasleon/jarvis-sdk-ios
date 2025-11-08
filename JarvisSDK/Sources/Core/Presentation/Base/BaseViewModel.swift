//
//  BaseViewModel.swift
//  JarvisSDK
//
//  Created by Jose Luis Dumas Leon   on 7/11/25.
//

import Combine

// MARK: - Base View Model

/// Base class for all Jarvis ViewModels
@MainActor
open class BaseViewModel: ObservableObject {
    @Published public var isLoading = false
    @Published public var error: Error?

    public init() {}

    /// Handle errors in a consistent way
    public func handleError(_ error: Error) {
        self.error = error
        self.isLoading = false
    }

    /// Clear current error
    public func clearError() {
        self.error = nil
    }
}

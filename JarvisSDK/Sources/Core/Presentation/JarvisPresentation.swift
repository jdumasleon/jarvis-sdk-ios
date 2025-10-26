import SwiftUI
import DesignSystem

/// Presentation layer for the Jarvis SDK
/// Contains ViewModels, ViewStates, and presentation logic
public struct JarvisPresentation {
    public static let version = "1.0.0"
}

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

// MARK: - View States

/// Generic view state for data loading
public enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error)

    public var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }

    public var data: T? {
        if case .loaded(let data) = self {
            return data
        }
        return nil
    }

    public var error: Error? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }
}

// MARK: - List View State

/// Specialized view state for lists
public enum ListViewState<T> {
    case idle
    case loading
    case loaded([T])
    case empty
    case error(Error)

    public var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }

    public var items: [T] {
        if case .loaded(let items) = self {
            return items
        }
        return []
    }

    public var isEmpty: Bool {
        if case .empty = self {
            return true
        }
        return false
    }

    public var error: Error? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }
}

// MARK: - Presentation Models

/// Presentation model for network requests
public struct NetworkRequestPresentationModel: Identifiable {
    public let id: String
    public let method: String
    public let url: String
    public let statusCode: Int?
    public let duration: String?
    public let size: String?
    public let timestamp: Date
    public let isSuccess: Bool

    public init(
        id: String,
        method: String,
        url: String,
        statusCode: Int? = nil,
        duration: String? = nil,
        size: String? = nil,
        timestamp: Date,
        isSuccess: Bool = false
    ) {
        self.id = id
        self.method = method
        self.url = url
        self.statusCode = statusCode
        self.duration = duration
        self.size = size
        self.timestamp = timestamp
        self.isSuccess = isSuccess
    }
}

// MARK: - View Modifiers

public extension View {
    /// Apply loading state overlay
    func loadingOverlay(_ isLoading: Bool) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    DSLoadingState()
                        .background(DSColor.Extra.white.opacity(0.8))
                }
            }
        )
    }

    /// Apply error handling
    func errorAlert(_ error: Binding<Error?>) -> some View {
        self.alert("Error", isPresented: .constant(error.wrappedValue != nil)) {
            Button("OK") {
                error.wrappedValue = nil
            }
        } message: {
            Text(error.wrappedValue?.localizedDescription ?? "")
        }
    }
}
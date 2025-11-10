//
//  ListViewState.swift
//  JarvisSDK
//
//  Created by Jose Luis Dumas Leon   on 7/11/25.
//

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

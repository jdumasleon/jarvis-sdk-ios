//
//  ViewState.swift
//  JarvisSDK
//
//  Created by Jose Luis Dumas Leon   on 7/11/25.
//

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

//
//  HomeViewModel.swift
//  Jarvis
//
//  Created by Jose Luis Dumas Leon   on 30/9/25.
//

import SwiftUI
import Combine

// MARK: - Home View Model

@MainActor
public class HomeViewModel: ObservableObject {
    @Published public var inspectorStats = InspectorStats()
    @Published public var preferencesStats = PreferencesStats()
    @Published public var isLoading = false

    public init() {}

    public func loadStats() async {
        isLoading = true

        // Load inspector and preferences statistics
        // Implementation will be added later

        isLoading = false
    }
}

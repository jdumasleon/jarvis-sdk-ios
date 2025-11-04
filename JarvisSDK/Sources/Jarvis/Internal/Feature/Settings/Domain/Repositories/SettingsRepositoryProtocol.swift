//
//  SettingsRepositoryProtocol.swift
//  JarvisSDK
//
//  Repository protocol for settings data
//

import Foundation

/// Protocol for managing settings data
public protocol SettingsRepositoryProtocol {
    /// Get application information (SDK + Host App)
    func getSettingsAppInfo() async throws -> SettingsAppInfo
}

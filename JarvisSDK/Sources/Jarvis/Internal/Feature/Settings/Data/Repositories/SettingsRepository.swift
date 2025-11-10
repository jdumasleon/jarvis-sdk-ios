//
//  SettingsRepository.swift
//  JarvisSDK
//
//  Repository implementation for settings data
//

import Foundation

/// Repository for managing settings data
public class SettingsRepository: SettingsRepositoryProtocol {

    private let appInfoProvider: AppInfoProvider

    public init(appInfoProvider: AppInfoProvider? = nil) {
        self.appInfoProvider = appInfoProvider ?? AppInfoProvider()
    }

    public func getSettingsAppInfo() async throws -> SettingsAppInfo {
        return appInfoProvider.getSettingsAppInfo()
    }
}

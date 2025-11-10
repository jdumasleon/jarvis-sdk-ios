//
//  AppInfo.swift
//  JarvisSDK
//
//  Application and SDK information entities
//

import Foundation

/// Contains SDK-specific information
public struct SdkInfo {
    public let name: String
    public let version: String
    public let buildNumber: String

    public init(
        name: String = "Jarvis SDK",
        version: String,
        buildNumber: String
    ) {
        self.name = name
        self.version = version
        self.buildNumber = buildNumber
    }
}

/// Contains host application information
public struct HostAppInfo {
    public let appName: String
    public let version: String
    public let buildNumber: String
    public let bundleIdentifier: String
    public let minimumOSVersion: String?
    public let targetOSVersion: String?

    public init(
        appName: String,
        version: String,
        buildNumber: String,
        bundleIdentifier: String,
        minimumOSVersion: String? = nil,
        targetOSVersion: String? = nil
    ) {
        self.appName = appName
        self.version = version
        self.buildNumber = buildNumber
        self.bundleIdentifier = bundleIdentifier
        self.minimumOSVersion = minimumOSVersion
        self.targetOSVersion = targetOSVersion
    }
}

/// Combined information for settings screen
public struct SettingsAppInfo {
    public let sdkInfo: SdkInfo
    public let hostAppInfo: HostAppInfo

    public init(sdkInfo: SdkInfo, hostAppInfo: HostAppInfo) {
        self.sdkInfo = sdkInfo
        self.hostAppInfo = hostAppInfo
    }
}

/// Mock data for development and previews
public struct AppInfoMock {
    public static let mockSdkInfo = SdkInfo(
        version: "1.0.0",
        buildNumber: "1"
    )

    public static let mockHostAppInfo = HostAppInfo(
        appName: "Jarvis Demo",
        version: "1.0.0",
        buildNumber: "1",
        bundleIdentifier: "com.jarvis.demo",
        minimumOSVersion: "16.0",
        targetOSVersion: "17.0"
    )

    public static let mockSettingsAppInfo = SettingsAppInfo(
        sdkInfo: mockSdkInfo,
        hostAppInfo: mockHostAppInfo
    )
}

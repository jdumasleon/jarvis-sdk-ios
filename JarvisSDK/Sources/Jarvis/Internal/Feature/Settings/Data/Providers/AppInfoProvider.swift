//
//  AppInfoProvider.swift
//  JarvisSDK
//
//  Provider for retrieving application and SDK information
//

import Foundation

/// Provider for retrieving application and SDK information from Bundle
public class AppInfoProvider {

    public init() {}

    /// Get SDK information
    public func getSdkInfo() -> SdkInfo {
        // SDK version from the framework's bundle
        let sdkBundle = Bundle(for: type(of: self))
        let version = sdkBundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        let buildNumber = sdkBundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"

        return SdkInfo(
            name: "Jarvis SDK",
            version: version,
            buildNumber: buildNumber
        )
    }

    /// Get host application information
    public func getHostAppInfo() -> HostAppInfo {
        // Host app information from main bundle
        let mainBundle = Bundle.main
        let appName = mainBundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? mainBundle.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "Unknown App"
        let version = mainBundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        let buildNumber = mainBundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        let bundleIdentifier = mainBundle.bundleIdentifier ?? "unknown"

        // iOS version information
        let minimumOSVersion = mainBundle.object(forInfoDictionaryKey: "MinimumOSVersion") as? String
        let targetOSVersion = mainBundle.object(forInfoDictionaryKey: "DTPlatformVersion") as? String

        return HostAppInfo(
            appName: appName,
            version: version,
            buildNumber: buildNumber,
            bundleIdentifier: bundleIdentifier,
            minimumOSVersion: minimumOSVersion,
            targetOSVersion: targetOSVersion
        )
    }

    /// Get combined settings app info
    public func getSettingsAppInfo() -> SettingsAppInfo {
        let sdkInfo = getSdkInfo()
        let hostAppInfo = getHostAppInfo()
        return SettingsAppInfo(sdkInfo: sdkInfo, hostAppInfo: hostAppInfo)
    }
}

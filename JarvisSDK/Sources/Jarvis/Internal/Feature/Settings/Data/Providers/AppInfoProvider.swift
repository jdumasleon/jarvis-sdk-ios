//
//  AppInfoProvider.swift
//  JarvisSDK
//
//  Provider for retrieving application and SDK information
//

import Foundation
import JarvisResources

/// Provider for retrieving application and SDK information from Bundle
public class AppInfoProvider {

    public init() {}

    /// Get SDK information
    public func getSdkInfo() -> SdkInfo {
        // SDK version from the framework's bundle
        let sdkBundle = JarvisResourcesBundle.bundle
        guard
            let url = sdkBundle.url(forResource: "JarvisSDKInfo", withExtension: "plist"),
            let dict = NSDictionary(contentsOf: url) as? [String: Any]
        else { return SdkInfo(name: "Jarvis SDK", version: "1.0.0", buildNumber: "1") }
        
        let version = dict["JarvisSDKVersion"] as? String ?? "1.0.0"
        let build   = dict["JarvisSDKBuild"] as? String ?? "1"
        return SdkInfo(name: "Jarvis SDK", version: version, buildNumber: build)
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


public extension Bundle {
    subscript(key: String) -> Any? { object(forInfoDictionaryKey: key) }
}

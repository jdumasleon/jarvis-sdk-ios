//
//  JarvisResourcesBundle.swift
//  JarvisSDK
//
//  Created by Jose Luis Dumas Leon   on 26/10/25.
//

import Foundation

public enum JarvisResourcesBundle {
    public static var bundle: Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        return Bundle(for: _BundleFinder.self)
        #endif
    }
}

public enum JarvisInternalConfig {
    public static let shared: (posthogKey: String, posthogHost: String, sentryDSN: String) = {
        guard let url = Bundle.module.url(forResource: "JarvisInternalConfig", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else {
            return ("", "", "")
        }

        let posthogKey = dict["PostHogKey"] as? String ?? ""
        let posthogHost = dict["PostHogHost"] as? String ?? ""
        let sentryDSN = dict["SentryDSN"] as? String ?? ""
        return (posthogKey, posthogHost, sentryDSN)
    }()
}

private final class _BundleFinder {}

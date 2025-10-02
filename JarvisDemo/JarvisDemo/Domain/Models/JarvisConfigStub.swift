//
//  JarvisConfigStub.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 2/10/25.
//

import Foundation

// TODO: Remove this stub once Jarvis SDK module is available
// Temporary stub to allow demo app to compile without Jarvis SDK dependency

struct JarvisConfig {
    let enableDebugLogging: Bool
    let enableShakeDetection: Bool
    let networkInspection: NetworkInspectionConfig
    let preferences: PreferencesConfig

    init(
        enableDebugLogging: Bool = false,
        enableShakeDetection: Bool = false,
        networkInspection: NetworkInspectionConfig = NetworkInspectionConfig(),
        preferences: PreferencesConfig = PreferencesConfig()
    ) {
        self.enableDebugLogging = enableDebugLogging
        self.enableShakeDetection = enableShakeDetection
        self.networkInspection = networkInspection
        self.preferences = preferences
    }
}

struct NetworkInspectionConfig {
    let enableNetworkLogging: Bool
    let enableRequestLogging: Bool
    let enableResponseLogging: Bool

    init(
        enableNetworkLogging: Bool = false,
        enableRequestLogging: Bool = false,
        enableResponseLogging: Bool = false
    ) {
        self.enableNetworkLogging = enableNetworkLogging
        self.enableRequestLogging = enableRequestLogging
        self.enableResponseLogging = enableResponseLogging
    }
}

struct PreferencesConfig {
    let enableUserDefaultsMonitoring: Bool

    init(enableUserDefaultsMonitoring: Bool = false) {
        self.enableUserDefaultsMonitoring = enableUserDefaultsMonitoring
    }
}

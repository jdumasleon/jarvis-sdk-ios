//
//  DeviceInfo.swift
//  Platform
//
//  Platform device information
//

import Foundation
#if os(iOS)
import UIKit
#endif

/// Platform device information
public struct DeviceInfo {
    public let model: String
    public let systemName: String
    public let systemVersion: String
    public let identifier: String

    public init() {
        #if os(iOS)
        let device = UIDevice.current
        self.model = device.model
        self.systemName = device.systemName
        self.systemVersion = device.systemVersion
        self.identifier = device.identifierForVendor?.uuidString ?? "unknown"
        #elseif os(macOS)
        self.model = "Mac"
        self.systemName = "macOS"
        self.systemVersion = ProcessInfo.processInfo.operatingSystemVersionString
        self.identifier = "unknown"
        #else
        self.model = "unknown"
        self.systemName = "unknown"
        self.systemVersion = "unknown"
        self.identifier = "unknown"
        #endif
    }
}

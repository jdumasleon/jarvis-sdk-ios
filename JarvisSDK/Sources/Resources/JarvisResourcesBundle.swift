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
private final class _BundleFinder {}

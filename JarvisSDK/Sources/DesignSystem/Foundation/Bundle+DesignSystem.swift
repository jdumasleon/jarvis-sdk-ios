import Foundation

private final class DesignSystemBundleToken {}

public extension Bundle {
    static var designSystemModule: Bundle = {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: DesignSystemBundleToken.self)
        #endif
    }()
}

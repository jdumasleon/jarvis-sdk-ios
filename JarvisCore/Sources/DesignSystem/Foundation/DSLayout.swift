import SwiftUI

/// Design System Layout Helpers - consistent layout values and breakpoints
public struct DSLayout {
    // Common screen breakpoints
    public static let compactWidth: CGFloat = 375
    public static let regularWidth: CGFloat = 768
    public static let wideWidth: CGFloat = 1024

    // Common heights
    public static let minTouchTarget: CGFloat = 44
    public static let toolbarHeight: CGFloat = 56
    public static let tabBarHeight: CGFloat = 64
    public static let listRowHeight: CGFloat = 56

    // Container spacing
    public static let containerPadding: CGFloat = 16
    public static let sectionSpacing: CGFloat = 24
}
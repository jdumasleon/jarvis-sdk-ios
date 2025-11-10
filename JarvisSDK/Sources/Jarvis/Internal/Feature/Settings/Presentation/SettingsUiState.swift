//
//  SettingsUIState.swift
//  JarvisSDK
//
//  UI state for Settings screen
//

import Foundation

/// UI state for the Settings screen
public struct SettingsUIState {
    public var settingsGroups: [SettingsGroup]
    public var selectedItem: SettingsItem?
    public var showAppDetails: Bool
    public var appInfo: SettingsAppInfo?
    public var isLoading: Bool
    public var error: Error?

    // Rating state
    public var showRatingDialog: Bool
    public var ratingStars: Int
    public var ratingDescription: String
    public var isSubmittingRating: Bool

    public init(
        settingsGroups: [SettingsGroup] = [],
        selectedItem: SettingsItem? = nil,
        showAppDetails: Bool = false,
        appInfo: SettingsAppInfo? = nil,
        isLoading: Bool = false,
        error: Error? = nil,
        showRatingDialog: Bool = false,
        ratingStars: Int = 0,
        ratingDescription: String = "",
        isSubmittingRating: Bool = false
    ) {
        self.settingsGroups = settingsGroups
        self.selectedItem = selectedItem
        self.showAppDetails = showAppDetails
        self.appInfo = appInfo
        self.isLoading = isLoading
        self.error = error
        self.showRatingDialog = showRatingDialog
        self.ratingStars = ratingStars
        self.ratingDescription = ratingDescription
        self.isSubmittingRating = isSubmittingRating
    }
}

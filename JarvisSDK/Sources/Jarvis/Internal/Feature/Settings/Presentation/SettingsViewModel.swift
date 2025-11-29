//
//  SettingsViewModel.swift
//  JarvisSDK
//
//  ViewModel for Settings screen
//

import SwiftUI
import Combine
#if canImport(Presentation)
import JarvisPresentation
#endif
import JarvisCommon

/// ViewModel for Settings screen
@MainActor
public class SettingsViewModel: BaseViewModel {
    @Published public var uiState = SettingsUIState()

    @Injected private var getSettingsItemsUseCase: GetSettingsItemsUseCase
    @Injected private var submitRatingUseCase: SubmitRatingUseCase

    public func loadSettings() {
        Task {
            isLoading = true
            clearError()

            do {
                let appInfo = try await getSettingsItemsUseCase.getAppInfo()
                let settingsGroups = try await getSettingsItemsUseCase.execute()
                uiState = SettingsUIState(
                    settingsGroups: settingsGroups,
                    selectedItem: uiState.selectedItem,
                    showAppDetails: uiState.showAppDetails,
                    appInfo: appInfo,
                    isLoading: false,
                    error: nil
                )
                isLoading = false
            } catch {
                handleError(error)
                uiState = SettingsUIState(
                    settingsGroups: uiState.settingsGroups,
                    selectedItem: uiState.selectedItem,
                    showAppDetails: uiState.showAppDetails,
                    appInfo: uiState.appInfo,
                    isLoading: false,
                    error: error
                )
            }
        }
    }

    /// Handle actions that don't require UI interaction (delegated from Screen)
    public func handleAction(_ action: SettingsAction) {
        switch action {
        case .version:
            // Version tap - could show additional info in future
            break

        case .openUrl(let urlString):
            if let url = URL(string: urlString) {
                #if canImport(UIKit)
                UIApplication.shared.open(url)
                #endif
            }

        case .openEmail(let email, let subject):
            let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let url = URL(string: "mailto:\(email)?subject=\(encodedSubject)") {
                #if canImport(UIKit)
                UIApplication.shared.open(url)
                #endif
            }

        // These cases should be handled by the Screen, not ViewModel
        case .rateApp, .navigateToInspector, .navigateToPreferences, .navigateToLogging, .showCallingAppDetails, .shareApp:
            assertionFailure("Action \(action) should be handled by the Screen, not ViewModel")
        }
    }

    public func dismissAppDetails() {
        uiState.showAppDetails = false
    }

    // MARK: - Rating Methods

    public func showRatingDialog() {
        uiState.showRatingDialog = true
    }

    public func hideRatingDialog() {
        uiState.showRatingDialog = false
        uiState.ratingStars = 0
        uiState.ratingDescription = ""
        uiState.isSubmittingRating = false
    }

    public func updateRatingStars(_ stars: Int) {
        uiState.ratingStars = stars
    }

    public func updateRatingDescription(_ description: String) {
        uiState.ratingDescription = description
    }

    public func submitRating() {
        Task {
            uiState.isSubmittingRating = true

            do {
                // Create rating entity
                let rating = Rating(
                    stars: uiState.ratingStars,
                    description: uiState.ratingDescription.isEmpty ? "awesome" : uiState.ratingDescription,
                    userId: nil, // Could get from user session if available
                    version: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                )

                // Submit rating via use case
                let result = try await submitRatingUseCase.execute(rating)

                if result.success {
                    print("Rating submitted successfully! Submission ID: \(result.submissionId ?? "N/A")")
                    // Hide dialog after successful submission
                    hideRatingDialog()
                } else {
                    throw NSError(
                        domain: "JarvisSDK",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to submit rating"]
                    )
                }
            } catch {
                uiState.isSubmittingRating = false
                print("Error submitting rating: \(error.localizedDescription)")
                handleError(error)
            }
        }
    }
}

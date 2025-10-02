import SwiftUI
import JarvisCommon
import JarvisDesignSystem
import JarvisNavigation
import JarvisPresentation
import JarvisPreferencesDomain
import JarvisPreferencesData

/// Preferences monitoring presentation layer
/// Contains ViewModels and UI components for preferences monitoring
public struct JarvisPreferencesPresentation {
    public static let version = "1.0.0"
}

// MARK: - Preferences View Model

@MainActor
public class PreferencesViewModel: BaseViewModel {
    @Published public var preferences: ListViewState<PreferenceChangeViewModel> = .idle
    @Published public var selectedFilter: PreferenceFilter = .all

    private let repository = PreferencesRepository()

    public override init() {
        super.init()
    }

    public func loadPreferences() async {
        preferences = .loading

        do {
            let data = try await repository.fetchAll()
            let viewModels = data.map { PreferenceChangeViewModel(data: $0) }

            if viewModels.isEmpty {
                preferences = .empty
            } else {
                preferences = .loaded(viewModels)
            }
        } catch {
            preferences = .error(error)
            handleError(error)
        }
    }

    public func filterPreferences(by filter: PreferenceFilter) {
        selectedFilter = filter
        // Apply filtering logic
    }
}

// MARK: - Preference Change View Model

public class PreferenceChangeViewModel: ObservableObject, Identifiable {
    public let id: String
    public let key: String
    public let oldValue: String?
    public let newValue: String?
    public let timestamp: Date
    public let source: String

    public init(data: PreferenceChangeData) {
        self.id = data.id
        self.key = data.key
        self.oldValue = data.oldValue
        self.newValue = data.newValue
        self.timestamp = data.timestamp
        self.source = data.source
    }

    public var displayTitle: String {
        key
    }

    public var displaySubtitle: String {
        "\(source) • \(timestamp.jarvisTimestamp)"
    }

    public var displayValue: String {
        if let newValue = newValue {
            return newValue
        }
        return "nil"
    }
}

// MARK: - Filter Options

public enum PreferenceFilter: String, CaseIterable {
    case all = "All"
    case userDefaults = "UserDefaults"
    case keychain = "Keychain"
    case coreData = "CoreData"
    case cloudKit = "CloudKit"

    public var displayName: String {
        rawValue
    }
}

// MARK: - Preferences List View

public struct PreferencesListView: View {
    @StateObject private var viewModel = PreferencesViewModel()

    public init() {}

    public var body: some View {
        NavigationView {
            VStack(spacing: DSSpacing.none) {
                // Filter segmented control
                DSSegmentedControl(
                    selectedSegment: .constant(viewModel.selectedFilter.rawValue),
                    segments: PreferenceFilter.allCases.map { filter in
                        DSSegmentedControl.Segment(
                            id: filter.rawValue,
                            title: filter.displayName
                        )
                    }
                )
                .dsPadding(.horizontal, DSSpacing.m)
                .dsPadding(.top, DSSpacing.s)

                // Content
                switch viewModel.preferences {
                case .idle, .loading:
                    DSLoadingState(message: "Loading preferences...")
                        .frame(maxHeight: .infinity)

                case .loaded(let preferences):
                    List(preferences) { preference in
                        PreferenceRowView(preference: preference)
                    }
                    .listStyle(.plain)

                case .empty:
                    DSEmptyState(
                        icon: DSIcons.Jarvis.preferences,
                        title: "No Preferences Found",
                        description: "No preference changes have been monitored yet.",
                        primaryAction: ("Refresh", {
                            Task {
                                await viewModel.loadPreferences()
                            }
                        })
                    )

                case .error(let error):
                    DSStatusCard(
                        status: .error,
                        title: "Failed to Load Preferences",
                        message: error.localizedDescription,
                        actionTitle: "Retry",
                        action: {
                            Task {
                                await viewModel.loadPreferences()
                            }
                        }
                    )
                    .dsPadding(DSSpacing.m)
                }
            }
            .navigationTitle("Preferences Monitor")
            .task {
                await viewModel.loadPreferences()
            }
        }
    }
}

// MARK: - Preference Row View

private struct PreferenceRowView: View {
    let preference: PreferenceChangeViewModel

    var body: some View {
        DSListRow(.init(
            title: preference.displayTitle,
            subtitle: preference.displaySubtitle,
            description: "Value: \(preference.displayValue)",
            leadingIcon: DSIcons.Jarvis.preferences,
            action: {
                // Navigate to detail view
            }
        ))
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 17.0, *)
#Preview("Preferences List") {
    PreferencesListView()
}
#endif
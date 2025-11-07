import SwiftUI
import DesignSystem
import Domain
import Presentation
import JarvisPreferencesDomain


/// Preferences navigation view with coordinator-based routing
@MainActor
public struct PreferencesNavigationView: View {
    @ObservedObject private var coordinator: PreferencesCoordinator
    @ObservedObject private var viewModel: PreferencesViewModel

    public init(coordinator: PreferencesCoordinator, viewModel: PreferencesViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack(path: $coordinator.routes) {
            PreferencesScreen(coordinator: coordinator, viewModel: viewModel)
                .navigationDestination(for: PreferencesCoordinator.Route.self) { route in
                    switch route {
                    case .preferenceDetail(let route):
                        PreferenceDetailView(preference: route.value)
                    case .editPreference(let route):
                        EditPreferenceView(preference: route.value)
                    }
                }
        }
    }
}

/// Main preferences inspector view
public struct PreferencesScreen: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    let coordinator: PreferencesCoordinator
    @ObservedObject var viewModel: PreferencesViewModel

    init(coordinator: PreferencesCoordinator, viewModel: PreferencesViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.none) {
                // Search and filter
                VStack(spacing: DSSpacing.s) {
                    DSSearchField(
                        text: .constant(viewModel.uiState.searchQuery),
                        placeholder: "Search preferences...",
                        onSearchSubmit: { query in
                            viewModel.search(query)
                        }
                    )

                    DSSegmentedControl(
                        selectedSegment: .constant(viewModel.uiState.filter.rawValue),
                        segments: PreferenceFilter.allCases.map { filter in
                            DSSegmentedControl.Segment(
                                id: filter.rawValue,
                                title: filter.displayName
                            )
                        }
                    )
                }
                .dsPadding(.horizontal, DSSpacing.m)
                .dsPadding(.top, DSSpacing.s)

                // Content
                if viewModel.isLoading {
                    DSLoadingState(message: "Scanning preferences...")
                        .frame(maxHeight: .infinity)
                } else if let error = viewModel.uiState.error {
                    DSStatusCard(
                        status: .error,
                        title: "Failed to Load Preferences",
                        message: error.localizedDescription,
                        actionTitle: "Retry",
                        action: {
                            viewModel.loadPreferences()
                        }
                    )
                    .dsPadding(DSSpacing.m)
                } else if viewModel.uiState.filteredPreferences.isEmpty {
                    DSEmptyState(
                        icon: DSIcons.Jarvis.preferences,
                        title: "No Preferences Found",
                        description: "No preferences were found in the host app.",
                        primaryAction: ("Refresh", {
                            viewModel.loadPreferences()
                        })
                    )
                } else {
                    List {
                        ForEach(viewModel.uiState.filteredPreferences, id: \.id) { preference in
                            PreferenceRowView(preference: preference) {
                                viewModel.deletePreference(
                                    key: preference.key,
                                    source: preference.source,
                                    suiteName: preference.suiteName
                                )
                            }
                            .onTapGesture {
                                viewModel.selectPreference(preference)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(DSColor.Extra.background0)
            .navigationTitle("Preferences")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    JarvisTopBarLogo()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    DSIconButton(
                        icon: DSIcons.Navigation.close,
                        style: .ghost,
                        size: .small,
                        tint: DSColor.Neutral.neutral100
                    ) {
                        coordinator.onDismissSDK?()
                    }
                }
                #endif
            }
            .onAppear {
                viewModel.loadPreferences()
            }
        }
    }
}

/// Row view for preference
public struct PreferenceRowView: View {
    let preference: Preference
    let onDelete: () -> Void

    public init(preference: Preference, onDelete: @escaping () -> Void) {
        self.preference = preference
        self.onDelete = onDelete
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack {
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text(preference.key)
                        .dsTextStyle(.bodyMedium)
                        .foregroundColor(DSColor.Neutral.neutral100)

                    if let suite = preference.suiteName {
                        Text("\(preference.source.rawValue) • \(suite)")
                            .dsTextStyle(.labelSmall)
                            .foregroundColor(DSColor.Neutral.neutral80)
                    } else {
                        Text(preference.source.rawValue)
                            .dsTextStyle(.labelSmall)
                            .foregroundColor(DSColor.Neutral.neutral80)
                    }
                }

                Spacer()

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(DSColor.Error.error100)
                }
                .buttonStyle(.plain)
            }

            HStack {
                Text("Value:")
                    .dsTextStyle(.labelSmall)
                    .foregroundColor(DSColor.Neutral.neutral80)
                Text(String(describing: preference.value))
                    .dsTextStyle(.labelSmall)
                    .foregroundColor(DSColor.Neutral.neutral100)
                    .lineLimit(2)
            }

            HStack {
                Text("Type:")
                    .dsTextStyle(.labelSmall)
                    .foregroundColor(DSColor.Neutral.neutral80)
                Text(preference.type)
                    .dsTextStyle(.labelSmall)
                    .foregroundColor(DSColor.Neutral.neutral100)
            }
        }
        .dsPadding(DSSpacing.s)
    }
}

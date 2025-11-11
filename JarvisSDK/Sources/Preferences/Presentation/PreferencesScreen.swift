import SwiftUI
import DesignSystem
import Domain
#if canImport(Presentation)
import Presentation
#endif
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

    @State private var showEditDialog = false
    @State private var showDeleteDialog = false
    @State private var showClearAllDialog = false

    init(coordinator: PreferencesCoordinator, viewModel: PreferencesViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: DSSpacing.none) {
            // Content with ScrollView containing search/filters and list
            if viewModel.isLoading && viewModel.uiState.filteredPreferences.isEmpty {
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
            } else {
                PreferencesListView(
                    count: viewModel.uiState.filteredPreferences.count,
                    filterName: viewModel.uiState.filter.displayName,
                    searchQuery: viewModel.uiState.searchQuery,
                    selectedFilter: viewModel.uiState.filter,
                    selectedType: viewModel.uiState.selectedType,
                    preferences: viewModel.uiState.filteredPreferences,
                    hasMorePages: viewModel.uiState.hasMorePages,
                    isLoadingMore: viewModel.uiState.isLoadingMore,
                    onRefreshTapped: { viewModel.loadPreferences() },
                    onClearAllTapped: { showClearAllDialog = true },
                    onSearchChange: { viewModel.search($0) },
                    onFilterChange: { viewModel.applyFilter($0) },
                    onTypeChange: { viewModel.filterByType($0) },
                    onEdit: { preference in
                        viewModel.selectPreference(preference)
                        showEditDialog = true
                    },
                    onDelete: { preference in
                        viewModel.selectPreference(preference)
                        showDeleteDialog = true
                    },
                    onSelect: { preference in
                        viewModel.selectPreference(preference)
                    },
                    onLoadMore: {
                        viewModel.loadMorePreferences()
                    }
                )
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
        .sheet(isPresented: $showEditDialog) {
            if let preference = viewModel.uiState.selectedPreference {
                EditPreferenceSheet(
                    preference: preference,
                    onSave: { newValue in
                        viewModel.updatePreference(
                            key: preference.key,
                            value: newValue,
                            source: preference.source,
                            suiteName: preference.suiteName
                        )
                        showEditDialog = false
                    },
                    onDismiss: { showEditDialog = false }
                )
            }
        }
        .alert("Delete Preference?", isPresented: $showDeleteDialog) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let preference = viewModel.uiState.selectedPreference {
                    viewModel.deletePreference(
                        key: preference.key,
                        source: preference.source,
                        suiteName: preference.suiteName
                    )
                }
            }
        } message: {
            if let preference = viewModel.uiState.selectedPreference {
                Text("Are you sure you want to delete '\(preference.key)'? This action cannot be undone.")
            }
        }
        .alert("Clear All Preferences?", isPresented: $showClearAllDialog) {
            Button("Cancel", role: .cancel) {}
            Button("Clear All", role: .destructive) {
                viewModel.clearAllPreferences(source: viewModel.uiState.filter)
                showClearAllDialog = false
            }
        } message: {
            Text("Are you sure you want to clear all \(viewModel.uiState.filter.displayName) preferences? This action cannot be undone and will delete all preference data.")
        }
    }
}

// MARK: - Search and Filters

private struct SearchAndFilters: View {
    let searchQuery: String
    let selectedFilter: PreferenceFilter
    let selectedType: String?
    let onSearchChange: (String) -> Void
    let onFilterChange: (PreferenceFilter) -> Void
    let onTypeChange: (String?) -> Void

    var body: some View {
        VStack(spacing: DSSpacing.s) {
            // Search Field
            DSSearchField(
                text: Binding(
                    get: { searchQuery },
                    set: { onSearchChange($0) }
                ),
                placeholder: "Search preferences...",
                backgroundColor: DSColor.Extra.white,
                onSearchSubmit: { query in
                    onSearchChange(query)
                }
            )
            .dsPadding(.horizontal, DSSpacing.m)

            // Storage Type Filter Chips
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                DSText(
                    "STORAGE",
                    style: .bodyMedium,
                    color: DSColor.Neutral.neutral100
                )
                .dsPadding(.top, DSSpacing.xs)
                .dsPadding(.horizontal, DSSpacing.m)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DSSpacing.xs) {
                        ForEach([PreferenceFilter.all, .userDefaults, .keychain, .propertyList], id: \.self) { filter in
                            DSFilterChip(
                                title: filter.displayName.uppercased(),
                                isSelected: selectedFilter == filter,
                                action: { onFilterChange(filter) }
                            )
                        }
                    }
                    .dsPadding(.horizontal, DSSpacing.m)
                }
            }

            // Type Filter Chips
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                DSText(
                    "TYPES",
                    style: .bodyMedium,
                    color: DSColor.Neutral.neutral100
                )
                .dsPadding(.horizontal, DSSpacing.m)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DSSpacing.xs) {
                        DSFilterChip(
                            title: "ALL",
                            isSelected: selectedType == nil,
                            action: { onTypeChange(nil) }
                        )

                        ForEach(["String", "Boolean", "Integer", "Float", "Double", "Array", "Dictionary", "Data"], id: \.self) { type in
                            DSFilterChip(
                                title: type.uppercased(),
                                isSelected: selectedType == type,
                                action: { onTypeChange(type) }
                            )
                        }
                    }
                    .dsPadding(.horizontal, DSSpacing.m)
                }
            }
        }
        .dsPadding(.top, DSSpacing.s)
    }
}

// MARK: - Preferences Header (Sticky)

private struct PreferencesHeader: View {
    let count: Int
    let filterName: String
    let onRefreshTapped: () -> Void
    let onClearAllTapped: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            DSText(
                "\(filterName.uppercased()) (\(count))",
                style: .bodyMedium,
                color: DSColor.Neutral.neutral100
            )

            Spacer()

            Menu {
                Button {
                    onRefreshTapped()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }

                Button(role: .destructive) {
                    onClearAllTapped()
                } label: {
                    Label("Clear All", systemImage: "trash.fill")
                }
            } label: {
                DSIcons.Navigation.more
                    .font(.system(size: DSDimensions.l))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DSColor.Extra.jarvisPink, DSColor.Extra.jarvisBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 30, height: 30)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)
        }
        .dsPadding(.vertical, DSSpacing.xxxs)
        .background(DSColor.Extra.background0)
    }
}

// MARK: - Preferences List View (with Infinite Scroll)

private struct PreferencesListView: View {
    let count: Int
    let filterName: String
    let searchQuery: String
    let selectedFilter: PreferenceFilter
    let selectedType: String?
    let preferences: [Preference]
    let hasMorePages: Bool
    let isLoadingMore: Bool
    let onRefreshTapped: () -> Void
    let onClearAllTapped: () -> Void
    let onSearchChange: (String) -> Void
    let onFilterChange: (PreferenceFilter) -> Void
    let onTypeChange: (String?) -> Void
    let onEdit: (Preference) -> Void
    let onDelete: (Preference) -> Void
    let onSelect: (Preference) -> Void
    let onLoadMore: () -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: DSSpacing.none) {
                // Search and Filters (scrollable)
                SearchAndFilters(
                    searchQuery: searchQuery,
                    selectedFilter: selectedFilter,
                    selectedType: selectedType,
                    onSearchChange: onSearchChange,
                    onFilterChange: onFilterChange,
                    onTypeChange: onTypeChange
                )
                .dsPadding(.bottom, DSSpacing.xs)
                
                if preferences.isEmpty {
                    DSEmptyState(
                        icon: DSIcons.Jarvis.preferences,
                        title: "No Preferences Found",
                        description: searchQuery.isEmpty ?
                        "No preferences were found in the host app." :
                            "No preferences match your search criteria",
                        primaryAction: searchQuery.isEmpty ?
                        ("Refresh", { onRefreshTapped() }) :
                            ("Clear Search", {
                                onSearchChange("")
                                onFilterChange(.all)
                                onTypeChange(nil)
                            })
                    )
                } else {
                    // Preferences List
                    LazyVStack(spacing: DSSpacing.s, pinnedViews: [.sectionHeaders]) {
                        Section {
                            ForEach(preferences, id: \.id) { preference in
                                PreferenceRowView(
                                    preference: preference,
                                    onEdit: { onEdit(preference) },
                                    onDelete: { onDelete(preference) }
                                )
                                .onTapGesture {
                                    onSelect(preference)
                                }
                                .onAppear {
                                    // Load more when reaching near the end
                                    if preference.id == preferences.last?.id && hasMorePages {
                                        onLoadMore()
                                    }
                                }
                            }

                            // Load More Indicator
                            if hasMorePages {
                                LoadMoreIndicator(
                                    isLoading: isLoadingMore,
                                    message: "Loading more preferences..."
                                )
                            } else if preferences.count > 50 {
                                VStack(spacing: DSSpacing.xs) {
                                    DSText(
                                        "Showing all \(preferences.count) preferences",
                                        style: .bodyMedium,
                                        color: DSColor.Neutral.neutral80
                                    )
                                }
                                .frame(maxWidth: .infinity)
                                .dsPadding(DSSpacing.m)
                                .background(DSColor.Extra.white)
                                .dsCornerRadius(DSRadius.m)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                        } header: {
                            // Sticky Preferences count and actions
                            PreferencesHeader(
                                count: count,
                                filterName: filterName,
                                onRefreshTapped: onRefreshTapped,
                                onClearAllTapped: onClearAllTapped
                            )
                        }
                    }
                    .dsPadding(.horizontal, DSSpacing.m)
                    .dsPadding(.vertical, DSSpacing.xs)
                }
            }
        }
        .refreshable {
            onLoadMore()
        }
    }
}

// MARK: - Preference Row

private struct PreferenceRowView: View {
    let preference: Preference
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            // Header: Source badge, Type badge, and action buttons
            HStack {
                // Source Badge
                Text(preference.source.rawValue)
                    .dsTextStyle(.labelSmall)
                    .dsPadding(.horizontal, DSSpacing.xs)
                    .dsPadding(.vertical, DSSpacing.xxs)
                    .background(sourceColor.opacity(0.2))
                    .foregroundColor(sourceColor)
                    .dsCornerRadius(DSRadius.s)

                // Type Badge
                Text(preference.type)
                    .dsTextStyle(.labelSmall)
                    .dsPadding(.horizontal, DSSpacing.xs)
                    .dsPadding(.vertical, DSSpacing.xxs)
                    .background(DSColor.Info.info100.opacity(0.2))
                    .foregroundColor(DSColor.Info.info100)
                    .dsCornerRadius(DSRadius.s)

                Spacer()

                // Edit Button
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(DSColor.Primary.primary100)
                        .font(.system(size: DSIconSize.s))
                }
                .buttonStyle(.plain)

                // Delete Button
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(DSColor.Error.error100)
                        .font(.system(size: DSIconSize.s))
                }
                .buttonStyle(.plain)
            }

            // Key
            Text(preference.key)
                .dsTextStyle(.bodyMedium)
                .foregroundColor(DSColor.Neutral.neutral100)
                .lineLimit(2)

            // Value
            HStack(alignment: .top, spacing: DSSpacing.xs) {
                Text("Value:")
                    .dsTextStyle(.labelSmall)
                    .foregroundColor(DSColor.Neutral.neutral80)

                let valueString = String(describing: preference.value)
                Text(valueString.prefix(100) + (valueString.count > 100 ? "..." : ""))
                    .dsTextStyle(.labelSmall)
                    .foregroundColor(DSColor.Neutral.neutral100)
                    .lineLimit(3)
            }

            // Suite Name (if present)
            if let suite = preference.suiteName {
                HStack(spacing: DSSpacing.xs) {
                    Text("Suite:")
                        .dsTextStyle(.labelSmall)
                        .foregroundColor(DSColor.Neutral.neutral80)
                    Text(suite)
                        .dsTextStyle(.labelSmall)
                        .foregroundColor(DSColor.Neutral.neutral60)
                }
            }
        }
        .dsPadding(DSSpacing.s)
        .background(DSColor.Extra.white)
        .dsCornerRadius(DSRadius.m)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private var sourceColor: Color {
        switch preference.source {
        case .userDefaults:
            return DSColor.Success.success100
        case .keychain:
            return DSColor.Warning.warning100
        case .propertyList:
            return DSColor.Primary.primary100
        }
    }
}

// MARK: - Previews

#if DEBUG
@available(iOS 15.0, *)
struct PreferencesScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview with data
            NavigationView {
                PreferencesScreen(
                    coordinator: PreferencesCoordinator(),
                    viewModel: PreviewPreferencesViewModel(withData: true)
                )
            }
            .previewDisplayName("With Data")

            // Preview empty
            NavigationView {
                PreferencesScreen(
                    coordinator: PreferencesCoordinator(),
                    viewModel: PreviewPreferencesViewModel(withData: false)
                )
            }
            .previewDisplayName("Empty State")

            // Preview loading
            NavigationView {
                PreferencesScreen(
                    coordinator: PreferencesCoordinator(),
                    viewModel: PreviewPreferencesViewModel(loading: true)
                )
            }
            .previewDisplayName("Loading")
        }
    }
}

// Mock ViewModel for Previews
@MainActor
class PreviewPreferencesViewModel: PreferencesViewModel {
    override func loadPreferences() { }
    
    init(withData: Bool = true, loading: Bool = false) {
        super.init()
        
        PreferencesDependencyRegistration.register()

        if loading {
            isLoading = true
        } else if withData {
            let mockPreferences = [
                Preference(
                    id: UUID().uuidString,
                    key: "user_name",
                    value: "John Doe",
                    type: "String",
                    source: .userDefaults,
                    suiteName: nil,
                    timestamp: Date()
                ),
                Preference(
                    id: UUID().uuidString,
                    key: "is_premium",
                    value: true,
                    type: "Boolean",
                    source: .userDefaults,
                    suiteName: nil,
                    timestamp: Date()
                ),
                Preference(
                    id: UUID().uuidString,
                    key: "login_count",
                    value: 42,
                    type: "Integer",
                    source: .userDefaults,
                    suiteName: nil,
                    timestamp: Date()
                )
            ]

            uiState = PreferencesUIState(
                preferences: mockPreferences,
                filteredPreferences: mockPreferences,
                selectedPreference: nil,
                filter: .all,
                searchQuery: "",
                selectedType: nil,
                isLoading: false,
                error: nil
            )
        }
    }
}
#endif

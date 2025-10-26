import SwiftUI
import DesignSystem
import Domain
import JarvisInspectorDomain

/// Main network inspector view with search, filters, and pagination
public struct NetworkInspectorView: View {
    @StateObject private var viewModel: NetworkInspectorViewModel
    @State private var showClearConfirmation = false

    public init(viewModel: NetworkInspectorViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: DSSpacing.none) {
                // Search and Filters Section
                VStack(spacing: DSSpacing.s) {
                    // Search Field
                    DSSearchField(
                        text: .constant(viewModel.uiState.searchQuery),
                        placeholder: "Search URL or method...",
                        onSearchSubmit: { query in
                            viewModel.search(query)
                        }
                    )

                    // Method Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DSSpacing.xs) {
                            // All Methods chip
                            FilterChip(
                                title: "All",
                                isSelected: viewModel.uiState.selectedMethod == nil,
                                action: {
                                    viewModel.filterByMethod(nil)
                                }
                            )

                            // Individual method chips
                            ForEach([HTTPMethod.GET, .POST, .PUT, .DELETE, .PATCH], id: \.self) { method in
                                FilterChip(
                                    title: method.rawValue,
                                    isSelected: viewModel.uiState.selectedMethod == method,
                                    action: {
                                        viewModel.filterByMethod(method)
                                    }
                                )
                            }
                        }
                        .dsPadding(.horizontal, DSSpacing.m)
                    }

                    // Status Category Filter
                    DSSegmentedControl(
                        selectedSegment: Binding(
                            get: { viewModel.uiState.selectedStatusCategory?.rawValue ?? StatusCategory.all.rawValue },
                            set: { selectedId in
                                let category = StatusCategory.allCases.first { $0.rawValue == selectedId }
                                viewModel.filterByStatusCategory(category)
                            }
                        ),
                        segments: StatusCategory.allCases.map { category in
                            DSSegmentedControl.Segment(
                                id: category.rawValue,
                                title: category.rawValue
                            )
                        }
                    )
                }
                .dsPadding(.horizontal, DSSpacing.m)
                .dsPadding(.top, DSSpacing.s)

                // Content Section
                if viewModel.isLoading {
                    DSLoadingState(message: "Loading network requests...")
                        .frame(maxHeight: .infinity)
                } else if let error = viewModel.uiState.error {
                    DSStatusCard(
                        status: .error,
                        title: "Failed to Load Requests",
                        message: error.localizedDescription,
                        actionTitle: "Retry",
                        action: {
                            viewModel.loadTransactions()
                        }
                    )
                    .dsPadding(DSSpacing.m)
                } else if viewModel.uiState.filteredTransactions.isEmpty {
                    DSEmptyState(
                        icon: "network",
                        title: "No Network Requests",
                        description: viewModel.uiState.searchQuery.isEmpty ?
                            "Network requests will appear here when your app makes them" :
                            "No requests match your search criteria",
                        primaryAction: viewModel.uiState.searchQuery.isEmpty ? nil : ("Clear Filters", {
                            viewModel.search("")
                            viewModel.filterByMethod(nil)
                            viewModel.filterByStatusCategory(.all)
                        })
                    )
                } else {
                    VStack(spacing: DSSpacing.none) {
                        // Transaction List
                        List {
                            ForEach(viewModel.uiState.filteredTransactions, id: \.id) { transaction in
                                NetworkTransactionRow(transaction: transaction)
                                    .onTapGesture {
                                        viewModel.selectTransaction(transaction)
                                    }
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await viewModel.loadTransactions()
                        }

                        // Pagination Controls
                        if viewModel.uiState.totalPages > 1 {
                            PaginationControls(
                                currentPage: viewModel.uiState.currentPage,
                                totalPages: viewModel.uiState.totalPages,
                                itemsPerPage: viewModel.uiState.itemsPerPage,
                                onPrevious: { viewModel.previousPage() },
                                onNext: { viewModel.nextPage() },
                                onItemsPerPageChanged: { count in
                                    viewModel.setItemsPerPage(count)
                                }
                            )
                            .dsPadding(.horizontal, DSSpacing.m)
                            .dsPadding(.vertical, DSSpacing.s)
                            .background(DSColor.Extra.background0)
                        }
                    }
                }
            }
            .navigationTitle("Network Inspector")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Clear All", role: .destructive) {
                            showClearConfirmation = true
                        }

                        Menu("Items per page") {
                            ForEach([20, 50, 100], id: \.self) { count in
                                Button("\(count) items") {
                                    viewModel.setItemsPerPage(count)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .confirmationDialog("Clear All Requests?", isPresented: $showClearConfirmation) {
                Button("Clear All", role: .destructive) {
                    viewModel.clearAll()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all captured network requests.")
            }
            .onAppear {
                viewModel.loadTransactions()
            }
        }
    }
}

// MARK: - Filter Chip Component

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        DSButton(
            title,
            style: isSelected ? .primary : .secondary,
            size: .small,
            action: action
        )
    }
}

// MARK: - Network Transaction Row

private struct NetworkTransactionRow: View {
    let transaction: NetworkTransaction

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack {
                // Method Badge
                Text(transaction.request.method.rawValue)
                    .dsTextStyle(.labelSmall)
                    .dsPadding(.horizontal, DSSpacing.xs)
                    .dsPadding(.vertical, DSSpacing.xxs)
                    .background(methodColor.opacity(0.2))
                    .foregroundColor(methodColor)
                    .dsCornerRadius(DSRadius.xs)

                // Status Badge
                if let response = transaction.response {
                    Text("\(response.statusCode)")
                        .dsTextStyle(.labelSmall)
                        .dsPadding(.horizontal, DSSpacing.xs)
                        .dsPadding(.vertical, DSSpacing.xxs)
                        .background(statusColor(response.statusCode).opacity(0.2))
                        .foregroundColor(statusColor(response.statusCode))
                        .dsCornerRadius(DSRadius.xs)
                }

                Spacer()

                // Duration
                if let duration = transaction.duration {
                    Text(formatDuration(duration))
                        .dsTextStyle(.labelSmall)
                        .foregroundColor(DSColor.Neutral.neutral80)
                }
            }

            // URL
            Text(transaction.request.url)
                .dsTextStyle(.bodyMedium)
                .foregroundColor(DSColor.Neutral.neutral100)
                .lineLimit(2)

            // Timestamp
            Text(formatTimestamp(transaction.startTime))
                .dsTextStyle(.labelSmall)
                .foregroundColor(DSColor.Neutral.neutral60)
        }
        .dsPadding(DSSpacing.s)
    }

    private var methodColor: Color {
        switch transaction.request.method {
        case .GET: return DSColor.Info.info100
        case .POST: return DSColor.Success.success100
        case .PUT: return DSColor.Warning.warning100
        case .DELETE: return DSColor.Error.error100
        case .PATCH: return DSColor.Primary.primary100
        default: return DSColor.Neutral.neutral60
        }
    }

    private func statusColor(_ code: Int) -> Color {
        switch code {
        case 200..<300: return DSColor.Success.success100
        case 300..<400: return DSColor.Info.info100
        case 400..<500: return DSColor.Warning.warning100
        case 500..<600: return DSColor.Error.error100
        default: return DSColor.Neutral.neutral60
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        if duration < 1 {
            return "\(Int(duration * 1000))ms"
        } else {
            return String(format: "%.2fs", duration)
        }
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Pagination Controls

private struct PaginationControls: View {
    let currentPage: Int
    let totalPages: Int
    let itemsPerPage: Int
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onItemsPerPageChanged: (Int) -> Void

    var body: some View {
        HStack {
            // Previous Button
            DSButton(
                "Previous",
                style: .secondary,
                size: .small,
                isEnabled: currentPage > 0,
                action: onPrevious
            )

            Spacer()

            // Page Info
            Text("Page \(currentPage + 1) of \(totalPages)")
                .dsTextStyle(.bodySmall)
                .foregroundColor(DSColor.Neutral.neutral80)

            Spacer()

            // Next Button
            DSButton(
                "Next",
                style: .secondary,
                size: .small,
                isEnabled: currentPage < totalPages - 1,
                action: onNext
            )
        }
    }
}

// MARK: - Loading State

private struct DSLoadingState: View {
    let message: String

    var body: some View {
        VStack(spacing: DSSpacing.m) {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.5)

            Text(message)
                .dsTextStyle(.bodyMedium)
                .foregroundColor(DSColor.Neutral.neutral80)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Empty State

private struct DSEmptyState: View {
    let icon: String
    let title: String
    let description: String
    let primaryAction: (String, () -> Void)?

    var body: some View {
        VStack(spacing: DSSpacing.m) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(DSColor.Neutral.neutral60)

            Text(title)
                .dsTextStyle(.titleMedium)
                .foregroundColor(DSColor.Neutral.neutral100)

            Text(description)
                .dsTextStyle(.bodyMedium)
                .foregroundColor(DSColor.Neutral.neutral80)
                .multilineTextAlignment(.center)
                .dsPadding(.horizontal, DSSpacing.l)

            if let (actionTitle, action) = primaryAction {
                DSButton(
                    actionTitle,
                    style: .primary,
                    size: .medium,
                    action: action
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .dsPadding(DSSpacing.l)
    }
}

// MARK: - Status Card

private struct DSStatusCard: View {
    enum Status {
        case error
        case warning
        case info
    }

    let status: Status
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(statusColor)

                Text(title)
                    .dsTextStyle(.titleSmall)
                    .foregroundColor(DSColor.Neutral.neutral100)
            }

            Text(message)
                .dsTextStyle(.bodySmall)
                .foregroundColor(DSColor.Neutral.neutral80)

            DSButton(
                actionTitle,
                style: .secondary,
                size: .small,
                action: action
            )
        }
        .dsPadding(DSSpacing.m)
        .background(statusColor.opacity(0.1))
        .dsCornerRadius(DSRadius.m)
    }

    private var statusColor: Color {
        switch status {
        case .error: return DSColor.Error.error100
        case .warning: return DSColor.Warning.warning100
        case .info: return DSColor.Info.info100
        }
    }

    private var iconName: String {
        switch status {
        case .error: return "exclamationmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
}

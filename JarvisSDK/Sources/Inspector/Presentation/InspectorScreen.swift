import SwiftUI
import DesignSystem
import Domain
import Presentation
import JarvisInspectorDomain

/// Inspector navigation view with coordinator-based routing
@MainActor
public struct InspectorNavigationView: View {
    @ObservedObject private var coordinator: InspectorCoordinator
    @ObservedObject private var viewModel: NetworkInspectorViewModel

    public init(coordinator: InspectorCoordinator, viewModel: NetworkInspectorViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack(path: $coordinator.routes) {
            InspectorScreen(coordinator: coordinator, viewModel: viewModel)
                .navigationDestination(for: InspectorCoordinator.Route.self) { route in
                    switch route {
                    case .transactionDetail(let id):
                        TransactionDetailView(transactionId: id)
                    }
                }
        }
    }
}

/// Main network inspector view with search, filters, and infinite scroll
public struct InspectorScreen: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    let coordinator: InspectorCoordinator
    @ObservedObject var viewModel: NetworkInspectorViewModel
    @State private var showClearConfirmation = false
    @State private var isSearchAndFiltersVisible = true
    @State private var accumulatedScrollDelta: CGFloat = 0

    init(coordinator: InspectorCoordinator, viewModel: NetworkInspectorViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.none) {
                // Search and Filters Section (Collapsible)
                if isSearchAndFiltersVisible {
                    VStack(spacing: DSSpacing.s) {
                        // Search Field
                        DSSearchField(
                            text: Binding(
                                get: { viewModel.uiState.searchQuery },
                                set: { viewModel.search($0) }
                            ),
                            placeholder: "Search URL or method...",
                            onSearchSubmit: { query in
                                viewModel.search(query)
                            }
                        )
                        
                        // HTTP Methods Label
                        HStack {
                            DSText(
                                "HTTP Methods",
                                style: .bodyMedium,
                                color: DSColor.Neutral.neutral100
                            )
                            Spacer()
                        }
                        .dsPadding(.horizontal, DSSpacing.m)
                        
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
                        
                        // Status Label
                        HStack {
                            DSText(
                                "Status",
                                style: .bodyMedium,
                                color: DSColor.Neutral.neutral100
                            )
                            Spacer()
                        }
                        .dsPadding(.horizontal, DSSpacing.m)
                        
                        // Status Category Filter Chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DSSpacing.xs) {
                                ForEach(StatusCategory.allCases, id: \.self) { category in
                                    FilterChip(
                                        title: category.rawValue,
                                        isSelected: viewModel.uiState.selectedStatusCategory == category ||
                                        (category == .all && viewModel.uiState.selectedStatusCategory == nil),
                                        action: {
                                            viewModel.filterByStatusCategory(category == .all ? nil : category)
                                        }
                                    )
                                }
                            }
                            .dsPadding(.horizontal, DSSpacing.m)
                        }
                    }
                    .dsPadding(.top, DSSpacing.s)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Transaction count and actions
                HStack {
                    DSText(
                        "TRANSACTIONS (\(viewModel.uiState.filteredTransactions.count))",
                        style: .bodyMedium,
                        color: DSColor.Neutral.neutral100
                    )
                    .textCase(.uppercase)
                    
                    Spacer()
                    
                    Menu {
                        Button(role: .destructive, action: {
                            showClearConfirmation = true
                        }) {
                            Label("Clear All", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [DSColor.Extra.jarvisPink, DSColor.Extra.jarvisBlue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .font(.title3)
                    }
                }
                .dsPadding(.horizontal, DSSpacing.m)
                .dsPadding(.vertical, DSSpacing.xs)
                
                // Content Section
                if viewModel.isLoading && viewModel.uiState.filteredTransactions.isEmpty {
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
                            viewModel.filterByStatusCategory(nil)
                        })
                    )
                } else {
                    // Infinite Scroll List with Scroll Detection
                    ScrollViewWithOffsetTracking(
                        onOffsetChange: { offset, delta in
                            handleScrollOffset(offset: offset, delta: delta)
                        }
                    ) {
                        LazyVStack(spacing: DSSpacing.s) {
                            ForEach(viewModel.uiState.filteredTransactions, id: \.id) { transaction in
                                NetworkTransactionRow(transaction: transaction)
                                    .onTapGesture {
                                        coordinator.showTransactionDetail(id: transaction.id)
                                    }
                                    .onAppear {
                                        // Load more when reaching near the end
                                        if transaction.id == viewModel.uiState.filteredTransactions.last?.id {
                                            viewModel.loadMoreTransactions()
                                        }
                                    }
                            }
                            
                            // Load More Indicator
                            if viewModel.uiState.hasMorePages {
                                LoadMoreIndicator(
                                    isLoading: viewModel.uiState.isLoadingMore,
                                    onLoadMore: {
                                        viewModel.loadMoreTransactions()
                                    }
                                )
                            }
                        }
                        .dsPadding(.horizontal, DSSpacing.m)
                        .dsPadding(.vertical, DSSpacing.xs)
                    }
                    .refreshable {
                        await viewModel.refreshTransactions()
                    }
                }
            }
        }
        .background(DSColor.Extra.background0)
        .navigationTitle("Inspector")
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

    // Handle scroll offset to show/hide search and filters
    private func handleScrollOffset(offset: CGFloat, delta: CGFloat) {
        let topResetThreshold: CGFloat = 16
        let collapseDistance: CGFloat = 70
        let expandThreshold: CGFloat = 20

        // Close to top? Always show.
        if offset <= topResetThreshold {
            if !isSearchAndFiltersVisible {
                print("Inspector: near top -> expand header. offset=\(offset)")
                withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                    isSearchAndFiltersVisible = true
                }
            }
            accumulatedScrollDelta = 0
            return
        }

        var newAccumulated = accumulatedScrollDelta

        if delta > 0 {
            print("Inspector: scrolling down delta=\(delta)")
            newAccumulated = min(collapseDistance, newAccumulated + delta)
        } else if delta < 0 {
            print("Inspector: scrolling up delta=\(delta)")
            newAccumulated = max(0, newAccumulated + delta)
        }

        if newAccumulated >= collapseDistance && isSearchAndFiltersVisible {
            print("Inspector: collapse triggered accumulate=\(newAccumulated)")
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                isSearchAndFiltersVisible = false
            }
        } else if newAccumulated <= expandThreshold && !isSearchAndFiltersVisible {
            print("Inspector: expand triggered accumulate=\(newAccumulated)")
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                isSearchAndFiltersVisible = true
            }
        }

        accumulatedScrollDelta = newAccumulated
    }
}

// MARK: - ScrollView with Offset Tracking

private struct ScrollViewWithOffsetTracking<Content: View>: View {
    let onOffsetChange: (CGFloat, CGFloat) -> Void
    let content: Content

    @State private var initialOffset: CGFloat?
    @State private var lastOffset: CGFloat = 0

    init(
        onOffsetChange: @escaping (CGFloat, CGFloat) -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.onOffsetChange = onOffsetChange
        self.content = content()
    }

    var body: some View {
        ScrollView {
            GeometryReader { proxy in
                let offset = proxy.frame(in: .named("InspectorScroll")).minY
                Color.clear
                    .preference(key: ScrollOffsetPreferenceKey.self, value: offset)
            }
            .frame(height: 0)

            content
        }
        .coordinateSpace(name: "InspectorScroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            guard value.isFinite else { return }

            if initialOffset == nil {
                initialOffset = value
                lastOffset = 0
                onOffsetChange(0, 0)
                return
            }

            guard let initialOffset else { return }

            let offset = initialOffset - value
            let delta = offset - lastOffset

            if abs(delta) > 0.5 {
                onOffsetChange(offset, delta)
                lastOffset = offset
            }
        }
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Filter Chip Component

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .dsTextStyle(.labelSmall)
                .dsPadding(.horizontal, DSSpacing.s)
                .dsPadding(.vertical, DSSpacing.xs)
                .background(
                    isSelected ?
                        LinearGradient(
                            colors: [DSColor.Extra.jarvisPink, DSColor.Extra.jarvisBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [DSColor.Neutral.neutral20, DSColor.Neutral.neutral20],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                )
                .foregroundColor(isSelected ? .white : DSColor.Neutral.neutral80)
                .dsCornerRadius(DSRadius.m)
        }
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
                } else {
                    Text(statusText)
                        .dsTextStyle(.labelSmall)
                        .dsPadding(.horizontal, DSSpacing.xs)
                        .dsPadding(.vertical, DSSpacing.xxs)
                        .background(statusColor(0).opacity(0.2))
                        .foregroundColor(statusColor(0))
                        .dsCornerRadius(DSRadius.xs)
                }

                Spacer()

                // Duration
                if let duration = transaction.duration {
                    Text(formatDuration(duration))
                        .dsTextStyle(.labelSmall)
                        .foregroundColor(DSColor.Neutral.neutral80)
                } else if let response = transaction.response {
                    Text("\(Int(response.responseTime * 1000))ms")
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
        .background(DSColor.Extra.white)
        .dsCornerRadius(DSRadius.m)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private var methodColor: Color {
        switch transaction.request.method {
        case .GET: return DSColor.Success.success100
        case .POST: return DSColor.Info.info100
        case .PUT: return DSColor.Warning.warning100
        case .DELETE: return DSColor.Error.error100
        case .PATCH: return DSColor.Primary.primary100
        default: return DSColor.Neutral.neutral60
        }
    }

    private var statusText: String {
        switch transaction.status {
        case .completed: return "Completed"
        case .failed: return "Failed"
        case .pending: return "Pending"
        case .cancelled: return "Cancelled"
        }
    }

    private func statusColor(_ code: Int) -> Color {
        if code == 0 {
            switch transaction.status {
            case .completed: return DSColor.Success.success100
            case .failed: return DSColor.Error.error100
            case .pending: return DSColor.Warning.warning100
            case .cancelled: return DSColor.Neutral.neutral60
            }
        }

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

// MARK: - Load More Indicator

private struct LoadMoreIndicator: View {
    let isLoading: Bool
    let onLoadMore: () -> Void

    var body: some View {
        VStack {
            if isLoading {
                HStack(spacing: DSSpacing.s) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(DSColor.Primary.primary100)

                    DSText(
                        "Loading more transactions...",
                        style: .bodyMedium,
                        color: DSColor.Neutral.neutral80
                    )
                }
                .dsPadding(DSSpacing.m)
                .frame(maxWidth: .infinity)
                .background(DSColor.Extra.white)
                .dsCornerRadius(DSRadius.m)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            } else {
                Button(action: onLoadMore) {
                    DSText(
                        "Tap to load more transactions",
                        style: .bodyMedium,
                        color: DSColor.Primary.primary100
                    )
                    .frame(maxWidth: .infinity)
                    .dsPadding(DSSpacing.m)
                    .background(DSColor.Extra.white)
                    .dsCornerRadius(DSRadius.m)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
            }
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
                .tint(DSColor.Primary.primary100)

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

// MARK: - Previews

#if DEBUG
#Preview("Inspector - Light Mode") {
    let coordinator = InspectorCoordinator()
    let viewModel = NetworkInspectorViewModel()

    return NavigationStack {
        InspectorScreen(coordinator: coordinator, viewModel: viewModel)
    }
}

#Preview("Inspector - Dark Mode") {
    let coordinator = InspectorCoordinator()
    let viewModel = NetworkInspectorViewModel()

    return NavigationStack {
        InspectorScreen(coordinator: coordinator, viewModel: viewModel)
    }
    .preferredColorScheme(.dark)
}

#Preview("Inspector - Loading") {
    let coordinator = InspectorCoordinator()
    let viewModel = NetworkInspectorViewModel()
    // Trigger loading state
    Task {
        await MainActor.run {
            viewModel.isLoading = true
        }
    }

    return NavigationStack {
        InspectorScreen(coordinator: coordinator, viewModel: viewModel)
    }
}

#Preview("Inspector - Empty") {
    let coordinator = InspectorCoordinator()
    let viewModel = NetworkInspectorViewModel()

    return NavigationStack {
        InspectorScreen(coordinator: coordinator, viewModel: viewModel)
    }
}
#endif

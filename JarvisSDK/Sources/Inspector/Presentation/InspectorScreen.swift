import SwiftUI
import JarvisDesignSystem
import JarvisDomain
#if canImport(JarvisPresentation)
import JarvisPresentation
#endif
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

    init(coordinator: InspectorCoordinator, viewModel: NetworkInspectorViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: DSSpacing.none) {
            // Content Section with ScrollView containing search/filters and list
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
            } else {
                TransactionListView(
                    count: viewModel.uiState.filteredTransactions.count,
                    searchQuery: viewModel.uiState.searchQuery,
                    selectedMethod: viewModel.uiState.selectedMethod,
                    selectedStatusCategory: viewModel.uiState.selectedStatusCategory,
                    transactions: viewModel.uiState.filteredTransactions,
                    hasMorePages: viewModel.uiState.hasMorePages,
                    isLoadingMore: viewModel.uiState.isLoadingMore,
                    onClearAllTapped: { showClearConfirmation = true },
                    onSearchChange: { viewModel.search($0) },
                    onMethodChange: { viewModel.filterByMethod($0) },
                    onStatusChange: { viewModel.filterByStatusCategory($0) },
                    onTransactionTapped: { transaction in
                        coordinator.showTransactionDetail(id: transaction.id)
                    },
                    onLoadMore: {
                        viewModel.loadMoreTransactions()
                    }
                )
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
        .alert("Clear All Requests?", isPresented: $showClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear All", role: .destructive) {
                viewModel.clearAll()
                showClearConfirmation = false
            }
        } message: {
            Text("This will permanently delete all captured network requests. This action cannot be undone.")
        }
        .onAppear {
            viewModel.loadTransactions()
        }
    }
}

// MARK: - Search and Filters

private struct SearchAndFilters: View {
    let searchQuery: String
    let selectedMethod: HTTPMethod?
    let selectedStatusCategory: StatusCategory?
    let onSearchChange: (String) -> Void
    let onMethodChange: (HTTPMethod?) -> Void
    let onStatusChange: (StatusCategory?) -> Void

    var body: some View {
        VStack(spacing: DSSpacing.s) {
            // Search Field
            DSSearchField(
                text: Binding(
                    get: { searchQuery },
                    set: { onSearchChange($0) }
                ),
                placeholder: "Search URL or method...",
                backgroundColor: DSColor.Extra.white,
                onSearchSubmit: { query in
                    onSearchChange(query)
                }
            )
            .dsPadding(.horizontal, DSSpacing.m)

            // HTTP Methods Filter
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                DSText(
                    "HTTP METHODS",
                    style: .bodyMedium,
                    color: DSColor.Neutral.neutral100
                )
                .dsPadding(.top, DSSpacing.xs)
                .dsPadding(.horizontal, DSSpacing.m)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DSSpacing.xs) {
                        DSFilterChip(
                            title: "All",
                            isSelected: selectedMethod == nil,
                            action: { onMethodChange(nil) }
                        )

                        ForEach([HTTPMethod.GET, .POST, .PUT, .DELETE, .PATCH], id: \.self) { method in
                            DSFilterChip(
                                title: method.rawValue,
                                isSelected: selectedMethod == method,
                                action: { onMethodChange(method) }
                            )
                        }
                    }
                    .dsPadding(.horizontal, DSSpacing.m)
                }
            }

            // Status Category Filter
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                DSText(
                    "STATUS",
                    style: .bodyMedium,
                    color: DSColor.Neutral.neutral100
                )
                .dsPadding(.horizontal, DSSpacing.m)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DSSpacing.xs) {
                        ForEach(StatusCategory.allCases, id: \.self) { category in
                            DSFilterChip(
                                title: category.rawValue.uppercased(),
                                isSelected: selectedStatusCategory == category ||
                                    (category == .all && selectedStatusCategory == nil),
                                action: {
                                    onStatusChange(category == .all ? nil : category)
                                }
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

// MARK: - Transaction Header (Sticky)

private struct TransactionHeader: View {
    let count: Int
    let onClearAllTapped: () -> Void

    var body: some View {
        HStack {
            DSText(
                "TRANSACTIONS (\(count))",
                style: .bodyMedium,
                color: DSColor.Neutral.neutral100
            )

            Spacer()

            Menu {
                Button {
                    // navigate to rules
                } label: {
                    Label("Rules (coming soon)", systemImage: "line.horizontal.3")
                }
                .disabled(true)

                Button(role: .destructive) {
                    onClearAllTapped()
                } label: {
                    Label("Clear All", systemImage: "trash")
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

// MARK: - Transaction List View (with Infinite Scroll)

private struct TransactionListView: View {
    let count: Int
    let searchQuery: String
    let selectedMethod: HTTPMethod?
    let selectedStatusCategory: StatusCategory?
    let transactions: [NetworkTransaction]
    let hasMorePages: Bool
    let isLoadingMore: Bool
    let onClearAllTapped: () -> Void
    let onSearchChange: (String) -> Void
    let onMethodChange: (HTTPMethod?) -> Void
    let onStatusChange: (StatusCategory?) -> Void
    let onTransactionTapped: (NetworkTransaction) -> Void
    let onLoadMore: () -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: DSSpacing.none) {
                // Search and Filters (scrollable)
                SearchAndFilters(
                    searchQuery: searchQuery,
                    selectedMethod: selectedMethod,
                    selectedStatusCategory: selectedStatusCategory,
                    onSearchChange: onSearchChange,
                    onMethodChange: onMethodChange,
                    onStatusChange: onStatusChange
                )
                .dsPadding(.bottom, DSSpacing.xs)
                
                if transactions.isEmpty {
                    DSEmptyState(
                        icon: DSIcons.Jarvis.inspector,
                        title: "No Network Requests",
                        description: searchQuery.isEmpty ?
                            "Network requests will appear here when your app makes them" :
                            "No requests match your search criteria",
                        primaryAction: searchQuery.isEmpty ? nil : ("Clear Filters", {
                            onSearchChange("")
                            onMethodChange(nil)
                            onStatusChange(nil)
                        })
                    )
                } else {
                    // Transactions List
                    LazyVStack(spacing: DSSpacing.s, pinnedViews: [.sectionHeaders]) {
                        Section {
                            ForEach(transactions, id: \.id) { transaction in
                                NetworkTransactionRow(transaction: transaction)
                                    .onTapGesture {
                                        onTransactionTapped(transaction)
                                    }
                                    .onAppear {
                                        // Load more when reaching near the end
                                        if transaction.id == transactions.last?.id && hasMorePages {
                                            onLoadMore()
                                        }
                                    }
                            }

                            // Load More Indicator
                            if hasMorePages {
                                LoadMoreIndicator(
                                    isLoading: isLoadingMore,
                                    message: "Loading more requests..."
                                )
                            } else if transactions.count > 50 {
                                VStack(spacing: DSSpacing.xs) {
                                    DSText(
                                        "Showing all \(transactions.count) requests",
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
                            // Sticky Transaction Header
                            TransactionHeader(
                                count: count,
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
                    .dsCornerRadius(DSRadius.s)

                // Status Code Badge
                if let statusCode = transaction.response?.statusCode {
                    Text("\(statusCode)")
                        .dsTextStyle(.labelSmall)
                        .dsPadding(.horizontal, DSSpacing.xs)
                        .dsPadding(.vertical, DSSpacing.xxs)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .dsCornerRadius(DSRadius.s)
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
        case .HEAD, .OPTIONS, .TRACE, .CONNECT: return DSColor.Neutral.neutral80
        }
    }

    private var statusColor: Color {
        guard let statusCode = transaction.response?.statusCode else {
            return DSColor.Neutral.neutral60
        }

        switch statusCode {
        case 200..<300: return DSColor.Success.success100
        case 300..<400: return DSColor.Info.info100
        case 400..<500: return DSColor.Warning.warning100
        case 500..<600: return DSColor.Error.error100
        default: return DSColor.Neutral.neutral60
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let milliseconds = Int(duration * 1000)
        if milliseconds < 1000 {
            return "\(milliseconds)ms"
        } else {
            let seconds = duration
            return String(format: "%.2fs", seconds)
        }
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

// MARK: - Previews

#if DEBUG
@available(iOS 15.0, *)
struct InspectorScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview with data
            NavigationView {
                InspectorScreen(
                    coordinator: InspectorCoordinator(),
                    viewModel: PreviewNetworkInspectorViewModel(withData: true)
                )
            }
            .previewDisplayName("With Data")

            // Preview empty
            NavigationView {
                InspectorScreen(
                    coordinator: InspectorCoordinator(),
                    viewModel: PreviewNetworkInspectorViewModel(withData: false)
                )
            }
            .previewDisplayName("Empty State")

            // Preview loading
            NavigationView {
                InspectorScreen(
                    coordinator: InspectorCoordinator(),
                    viewModel: PreviewNetworkInspectorViewModel(loading: true)
                )
            }
            .previewDisplayName("Loading")
        }
    }
}

// Mock ViewModel for Previews
@MainActor
class PreviewNetworkInspectorViewModel: NetworkInspectorViewModel {
    override func loadTransactions() { }
    
    init(withData: Bool = true, loading: Bool = false) {
        super.init()
        
        InspectorDependencyRegistration.register()

        if loading {
            isLoading = true
        } else if withData {
            let startTime1 = Date()
            let endTime1 = startTime1.addingTimeInterval(0.234)
            let startTime2 = Date().addingTimeInterval(-60)
            let endTime2 = startTime2.addingTimeInterval(0.456)

            let mockTransactions = [
                NetworkTransaction(
                    id: UUID().uuidString,
                    request: NetworkRequest(
                        url: "https://api.example.com/users",
                        method: .GET,
                        headers: ["Authorization": "Bearer token123"]
                    ),
                    response: NetworkResponse(
                        statusCode: 200,
                        headers: ["Content-Type": "application/json"],
                        body: nil,
                        responseTime: 234
                    ),
                    status: .completed,
                    startTime: startTime1,
                    endTime: endTime1
                ),
                NetworkTransaction(
                    id: UUID().uuidString,
                    request: NetworkRequest(
                        url: "https://api.example.com/posts",
                        method: .POST,
                        headers: ["Content-Type": "application/json"],
                        body: "{\"title\": \"Test\"}".data(using: .utf8)
                    ),
                    response: NetworkResponse(
                        statusCode: 201,
                        headers: ["Content-Type": "application/json"],
                        body: nil,
                        responseTime: 456
                    ),
                    status: .completed,
                    startTime: startTime2,
                    endTime: endTime2
                )
            ]

            uiState = NetworkInspectorUIState(
                transactions: mockTransactions,
                filteredTransactions: mockTransactions,
                searchQuery: "",
                selectedMethod: nil,
                selectedStatusCategory: nil,
                hasMorePages: false,
                isLoadingMore: false
            )
        }
    }
}
#endif

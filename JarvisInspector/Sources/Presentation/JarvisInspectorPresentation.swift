import SwiftUI
import Common
import DesignSystem
import Navigation
import Presentation
import Domain
import JarvisInspectorDomain
import JarvisInspectorData

/// Network inspector presentation layer
/// Contains ViewModels and UI components for network inspection
public struct JarvisInspectorPresentation {
    public static let version = "1.0.0"
}

// MARK: - Inspector View Model

@MainActor
public class InspectorViewModel: BaseViewModel {
    @Published public var transactions: ListViewState<NetworkTransactionViewModel> = .idle
    @Published public var selectedFilter: NetworkFilter = .all
    @Published public var searchText = ""

    private let repository = NetworkTransactionRepository()
    private let interceptor = NetworkInterceptor.shared

    public override init() {
        super.init()
        startMonitoring()
    }

    public func loadTransactions() async {
        transactions = .loading

        do {
            let data = try await repository.fetchAll()
            let viewModels = data.map { NetworkTransactionViewModel(transaction: $0) }

            if viewModels.isEmpty {
                transactions = .empty
            } else {
                transactions = .loaded(viewModels)
            }
        } catch {
            transactions = .error(error)
            handleError(error)
        }
    }

    public func filterTransactions(by filter: NetworkFilter) {
        selectedFilter = filter
        // Apply filtering logic
    }

    public func searchTransactions(_ text: String) {
        searchText = text
        // Apply search logic
    }

    public func clearTransactions() async {
        do {
            try await repository.deleteAll()
            transactions = .empty
        } catch {
            handleError(error)
        }
    }

    private func startMonitoring() {
        interceptor.startMonitoring()
    }

    public func stopMonitoring() {
        interceptor.stopMonitoring()
    }
}

// MARK: - Network Transaction View Model

public class NetworkTransactionViewModel: ObservableObject, Identifiable {
    public let id: String
    public let method: String
    public let url: String
    public let statusCode: Int?
    public let startTime: Date
    public let endTime: Date?
    public let status: String

    public init(transaction: NetworkTransaction) {
        self.id = transaction.id
        self.method = transaction.request.method.rawValue
        self.url = transaction.request.url
        self.statusCode = transaction.response?.statusCode
        self.startTime = transaction.startTime
        self.endTime = transaction.endTime
        self.status = transaction.status.rawValue
    }

    public var displayTitle: String {
        "\(method) \(url)"
    }

    public var displaySubtitle: String {
        if let statusCode = statusCode {
            return "\(statusCode) • \(duration)"
        }
        return status.capitalized
    }

    public var duration: String {
        guard let endTime = endTime else { return "..." }
        let interval = endTime.timeIntervalSince(startTime)
        return String(format: "%.0fms", interval * 1000)
    }

    public var statusIcon: Image {
        if let statusCode = statusCode {
            if statusCode >= 200 && statusCode < 300 {
                return DSIcons.Status.success
            } else if statusCode >= 400 {
                return DSIcons.Status.error
            }
        }
        return DSIcons.Status.loading
    }

    public var isSuccess: Bool {
        guard let statusCode = statusCode else { return false }
        return statusCode >= 200 && statusCode < 300
    }
}

// MARK: - Filter Options

public enum NetworkFilter: String, CaseIterable {
    case all = "All"
    case success = "Success"
    case error = "Error"
    case pending = "Pending"

    public var displayName: String {
        rawValue
    }
}

// MARK: - Inspector List View

public struct InspectorListView: View {
    @StateObject private var viewModel = InspectorViewModel()

    public init() {}

    public var body: some View {
        NavigationView {
            VStack(spacing: DSSpacing.none) {
                // Search and filter
                VStack(spacing: DSSpacing.s) {
                    DSSearchField(
                        text: .constant(viewModel.searchText),
                        placeholder: "Search requests...",
                        onSearchSubmit: { text in
                            viewModel.searchTransactions(text)
                        }
                    )

                    DSSegmentedControl(
                        selectedSegment: .constant(viewModel.selectedFilter.rawValue),
                        segments: NetworkFilter.allCases.map { filter in
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
                switch viewModel.transactions {
                case .idle, .loading:
                    DSLoadingState(message: "Loading network requests...")
                        .frame(maxHeight: .infinity)

                case .loaded(let transactions):
                    List(transactions) { transaction in
                        VStack(alignment: .leading, spacing: DSSpacing.xs) {
                            HStack {
                                Text(transaction.method)
                                    .setTextStyle(.labelSmall)
                                    .foregroundColor(.blue)
                                Spacer()
                                if let statusCode = transaction.statusCode {
                                    Text("\\(statusCode)")
                                        .setTextStyle(.labelSmall)
                                        .foregroundColor(transaction.isSuccess ? .green : .red)
                                }
                            }
                            Text(transaction.url)
                                .setTextStyle(.bodySmall)
                                .lineLimit(2)
                        }
                        .dsPadding(DSSpacing.s)
                    }
                    .listStyle(.plain)

                case .empty:
                    DSEmptyState(
                        icon: DSIcons.Jarvis.inspector,
                        title: "No Network Requests",
                        description: "Start using your app to see network requests appear here.",
                        primaryAction: ("Refresh", {
                            Task {
                                await viewModel.loadTransactions()
                            }
                        }),
                        secondaryAction: ("Clear All", {
                            Task {
                                await viewModel.clearTransactions()
                            }
                        })
                    )

                case .error(let error):
                    DSStatusCard(
                        status: .error,
                        title: "Failed to Load Requests",
                        message: error.localizedDescription,
                        actionTitle: "Retry",
                        action: {
                            Task {
                                await viewModel.loadTransactions()
                            }
                        }
                    )
                    .dsPadding(DSSpacing.m)
                }
            }
            .navigationTitle("Network Inspector")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    DSIconButton(
                        icon: DSIcons.Action.refresh,
                        style: .ghost,
                        action: {
                            Task {
                                await viewModel.loadTransactions()
                            }
                        }
                    )
                }
            }
            .task {
                await viewModel.loadTransactions()
            }
        }
    }
}


// MARK: - Preview

#if DEBUG
@available(iOS 17.0, *)
#Preview("Inspector List") {
    InspectorListView()
}
#endif

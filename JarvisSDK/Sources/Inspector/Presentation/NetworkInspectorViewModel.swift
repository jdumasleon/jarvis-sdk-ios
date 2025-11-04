import Foundation
import Combine
import Presentation
import Domain
import JarvisInspectorDomain
import Common

/// View model for network inspector
@MainActor
public class NetworkInspectorViewModel: BaseViewModel {
    @Published public var uiState = NetworkInspectorUIState()

    @Injected private var monitorUseCase: MonitorNetworkTransactionsUseCase
    @Injected private var getTransactionUseCase: GetNetworkTransactionUseCase
    @Injected private var filterUseCase: FilterNetworkTransactionsUseCase
    @Injected private var repository: NetworkTransactionRepositoryProtocol

    public override init() {
        super.init()
    }

    /// Initializer for testing with custom use cases
    public init(
        monitorNetworkTransactionsUseCase: MonitorNetworkTransactionsUseCase,
        getNetworkTransactionUseCase: GetNetworkTransactionUseCase,
        filterNetworkTransactionsUseCase: FilterNetworkTransactionsUseCase
    ) {
        super.init()
        self.monitorUseCase = monitorNetworkTransactionsUseCase
        self.getTransactionUseCase = getNetworkTransactionUseCase
        self.filterUseCase = filterNetworkTransactionsUseCase
        // Repository is still injected, as it's only used for deleteAll
        self.repository = DependencyContainer.shared.resolve(NetworkTransactionRepositoryProtocol.self)
    }

    // MARK: - Public Methods

    public func loadTransactions() {
        Task {
            isLoading = true
            clearError()

            do {
                let transactions = try await monitorUseCase.execute(())
                let totalPages = calculateTotalPages(count: transactions.count)

                uiState = NetworkInspectorUIState(
                    transactions: transactions,
                    filteredTransactions: applyPagination(to: transactions),
                    selectedTransaction: uiState.selectedTransaction,
                    filter: uiState.filter,
                    isLoading: false,
                    error: nil,
                    searchQuery: uiState.searchQuery,
                    selectedMethod: uiState.selectedMethod,
                    selectedStatusCategory: uiState.selectedStatusCategory,
                    currentPage: uiState.currentPage,
                    itemsPerPage: uiState.itemsPerPage,
                    totalPages: totalPages
                )
                isLoading = false
            } catch {
                handleError(error)
                uiState = NetworkInspectorUIState(
                    transactions: uiState.transactions,
                    filteredTransactions: uiState.filteredTransactions,
                    selectedTransaction: uiState.selectedTransaction,
                    filter: uiState.filter,
                    isLoading: false,
                    error: error,
                    searchQuery: uiState.searchQuery,
                    selectedMethod: uiState.selectedMethod,
                    selectedStatusCategory: uiState.selectedStatusCategory,
                    currentPage: uiState.currentPage,
                    itemsPerPage: uiState.itemsPerPage,
                    totalPages: uiState.totalPages
                )
            }
        }
    }

    public func search(_ query: String) {
        let filter = TransactionFilter(
            method: uiState.selectedMethod,
            statusCode: nil,
            searchTerm: query.isEmpty ? nil : query,
            timeRange: nil
        )

        applyFilters(
            searchQuery: query,
            method: uiState.selectedMethod,
            statusCategory: uiState.selectedStatusCategory,
            filter: filter
        )
    }

    public func filterByMethod(_ method: HTTPMethod?) {
        let filter = TransactionFilter(
            method: method,
            statusCode: nil,
            searchTerm: uiState.searchQuery.isEmpty ? nil : uiState.searchQuery,
            timeRange: nil
        )

        applyFilters(
            searchQuery: uiState.searchQuery,
            method: method,
            statusCategory: uiState.selectedStatusCategory,
            filter: filter
        )
    }

    public func filterByStatusCategory(_ category: StatusCategory?) {
        let filter = TransactionFilter(
            method: uiState.selectedMethod,
            statusCode: nil,
            searchTerm: uiState.searchQuery.isEmpty ? nil : uiState.searchQuery,
            timeRange: nil
        )

        applyFilters(
            searchQuery: uiState.searchQuery,
            method: uiState.selectedMethod,
            statusCategory: category,
            filter: filter
        )
    }

    public func setItemsPerPage(_ count: Int) {
        let totalPages = calculateTotalPages(count: uiState.filteredTransactions.count, itemsPerPage: count)

        uiState = NetworkInspectorUIState(
            transactions: uiState.transactions,
            filteredTransactions: uiState.filteredTransactions,
            selectedTransaction: uiState.selectedTransaction,
            filter: uiState.filter,
            isLoading: uiState.isLoading,
            error: uiState.error,
            searchQuery: uiState.searchQuery,
            selectedMethod: uiState.selectedMethod,
            selectedStatusCategory: uiState.selectedStatusCategory,
            currentPage: 0,
            itemsPerPage: count,
            totalPages: totalPages
        )
    }

    public func nextPage() {
        guard uiState.currentPage < uiState.totalPages - 1 else { return }

        uiState = NetworkInspectorUIState(
            transactions: uiState.transactions,
            filteredTransactions: uiState.filteredTransactions,
            selectedTransaction: uiState.selectedTransaction,
            filter: uiState.filter,
            isLoading: uiState.isLoading,
            error: uiState.error,
            searchQuery: uiState.searchQuery,
            selectedMethod: uiState.selectedMethod,
            selectedStatusCategory: uiState.selectedStatusCategory,
            currentPage: uiState.currentPage + 1,
            itemsPerPage: uiState.itemsPerPage,
            totalPages: uiState.totalPages
        )
    }

    public func previousPage() {
        guard uiState.currentPage > 0 else { return }

        uiState = NetworkInspectorUIState(
            transactions: uiState.transactions,
            filteredTransactions: uiState.filteredTransactions,
            selectedTransaction: uiState.selectedTransaction,
            filter: uiState.filter,
            isLoading: uiState.isLoading,
            error: uiState.error,
            searchQuery: uiState.searchQuery,
            selectedMethod: uiState.selectedMethod,
            selectedStatusCategory: uiState.selectedStatusCategory,
            currentPage: uiState.currentPage - 1,
            itemsPerPage: uiState.itemsPerPage,
            totalPages: uiState.totalPages
        )
    }

    public func clearAll() {
        Task {
            do {
                try await repository.deleteAll()
                await loadTransactions()
            } catch {
                handleError(error)
            }
        }
    }

    public func selectTransaction(_ transaction: NetworkTransaction) {
        uiState = NetworkInspectorUIState(
            transactions: uiState.transactions,
            filteredTransactions: uiState.filteredTransactions,
            selectedTransaction: transaction,
            filter: uiState.filter,
            isLoading: uiState.isLoading,
            error: uiState.error,
            searchQuery: uiState.searchQuery,
            selectedMethod: uiState.selectedMethod,
            selectedStatusCategory: uiState.selectedStatusCategory,
            currentPage: uiState.currentPage,
            itemsPerPage: uiState.itemsPerPage,
            totalPages: uiState.totalPages
        )
    }

    // MARK: - Private Methods

    private func applyFilters(
        searchQuery: String,
        method: HTTPMethod?,
        statusCategory: StatusCategory?,
        filter: TransactionFilter
    ) {
        Task {
            do {
                var filteredTransactions = try await filterUseCase.execute(filter)

                // Apply status category filter (client-side)
                if let category = statusCategory, category != .all,
                   let range = category.range {
                    filteredTransactions = filteredTransactions.filter { transaction in
                        guard let statusCode = transaction.response?.statusCode else { return false }
                        return range.contains(statusCode)
                    }
                }

                let totalPages = calculateTotalPages(count: filteredTransactions.count)
                let paginatedTransactions = applyPagination(to: filteredTransactions, page: 0)

                uiState = NetworkInspectorUIState(
                    transactions: uiState.transactions,
                    filteredTransactions: paginatedTransactions,
                    selectedTransaction: uiState.selectedTransaction,
                    filter: filter,
                    isLoading: false,
                    error: nil,
                    searchQuery: searchQuery,
                    selectedMethod: method,
                    selectedStatusCategory: statusCategory,
                    currentPage: 0,
                    itemsPerPage: uiState.itemsPerPage,
                    totalPages: totalPages
                )
            } catch {
                handleError(error)
            }
        }
    }

    private func applyPagination(to transactions: [NetworkTransaction], page: Int? = nil) -> [NetworkTransaction] {
        let currentPage = page ?? uiState.currentPage
        let startIndex = currentPage * uiState.itemsPerPage
        let endIndex = min(startIndex + uiState.itemsPerPage, transactions.count)

        guard startIndex < transactions.count else { return [] }

        return Array(transactions[startIndex..<endIndex])
    }

    private func calculateTotalPages(count: Int, itemsPerPage: Int? = nil) -> Int {
        let items = itemsPerPage ?? uiState.itemsPerPage
        return max(1, Int(ceil(Double(count) / Double(items))))
    }

    public func applyFilter(_ filter: TransactionFilter) {
        applyFilters(
            searchQuery: filter.searchTerm ?? "",
            method: filter.method,
            statusCategory: uiState.selectedStatusCategory,
            filter: filter
        )
    }
}
